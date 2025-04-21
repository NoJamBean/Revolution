# lambda_s3_web.tf

# --- Lambda 함수 정의 ---
data "archive_file" "lambda_s3_web_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_s3_web.zip" # 임시 zip 파일 경로

  # source 블록을 사용하여 인라인 코드 제공
  source {
    filename = "index.py"
    content = <<-EOF
import json
import boto3
import os
import requests
from aws_requests_auth.aws_auth import AWSRequestsAuth # SigV4 인증 라이브러리
from datetime import datetime
import logging

# 로거 설정
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# AWS 서비스 클라이언트 초기화
s3 = boto3.client('s3')

# 환경 변수에서 OpenSearch 엔드포인트 및 리전 정보 가져오기
opensearch_endpoint = os.environ['OPENSEARCH_ENDPOINT']
aws_region = os.environ.get('AWS_REGION', 'ap-northeast-2') # 기본값 설정

# --- SigV4 인증 설정 ---
# Lambda 실행 역할의 임시 자격 증명 사용
credentials = boto3.Session().get_credentials()
aws_auth = AWSRequestsAuth(aws_access_key=credentials.access_key,
                           aws_secret_access_key=credentials.secret_key,
                           aws_token=credentials.token,
                           aws_host=opensearch_endpoint,
                           aws_region=aws_region,
                           aws_service='es') # OpenSearch Service의 서비스 이름은 'es'

def lambda_handler(event, context):
    """
    Lambda 함수 핸들러. S3 이벤트 트리거를 받아 JSON 파일을 처리하고 OpenSearch로 전송합니다.
    """
    logger.info("Received event: " + json.dumps(event, indent=2))

    try:
        # S3 이벤트에서 버킷 이름과 객체 키 추출
        bucket = event['Records'][0]['s3']['bucket']['name']
        # 객체 키에 '+' 문자가 포함된 경우 공백으로 치환 (URL 인코딩 처리)
        key = event['Records'][0]['s3']['object']['key'].replace('+', ' ')
    except (KeyError, IndexError, TypeError) as e:
        # 이벤트 구조가 예상과 다를 경우 오류 로깅 및 종료
        logger.error(f"Could not extract bucket/key from event: {e}. Event structure might be incorrect.")
        return {'statusCode': 400, 'body': json.dumps('Invalid S3 event format')}

    try:
        # S3에서 객체(JSON 파일) 가져오기
        response = s3.get_object(Bucket=bucket, Key=key)
        # 객체 본문(Body) 읽기
        content = response['Body'].read()

        # --- 수정된 부분: gzip 압축 해제 제거 ---
        # S3 파일이 순수 JSON이므로 바로 UTF-8로 디코딩
        log_data_raw = content.decode('utf-8')
        # --- 여기까지 수정 ---

        # 디코딩된 문자열을 JSON 객체로 파싱
        log_data = json.loads(log_data_raw)
        # JSON 객체에서 'Records' 키에 해당하는 리스트 가져오기 (없으면 빈 리스트)
        records = log_data.get('Records', [])
        logger.info(f"Processing {len(records)} records from {key}")

        # 처리할 레코드가 없으면 성공 응답 반환
        if not records:
            logger.info("No records to send.")
            return {'statusCode': 200, 'body': json.dumps('No records found in the file.')}

        # --- OpenSearch Bulk API 페이로드 생성 ---
        bulk_payload_lines = [] # 각 라인을 저장할 리스트
        for record in records:
            try:
                # 레코드에서 이벤트 시간 추출 및 인덱스 이름 생성 (날짜 기반)
                event_time_str = record.get('eventTime')
                if event_time_str:
                    try:
                        # ISO 8601 형식 시간 문자열을 datetime 객체로 변환
                        dt_obj = datetime.fromisoformat(event_time_str.replace('Z', '+00:00'))
                        # 날짜 부분만 추출하여 인덱스 이름에 사용 (예: 'web-2025-04-21')
                        index_date_str = dt_obj.strftime('%Y-%m-%d')
                    except ValueError:
                        # 시간 파싱 실패 시 경고 로깅 및 현재 UTC 날짜 사용
                        logger.warning(f"Could not parse eventTime '{event_time_str}', using current date.")
                        index_date_str = datetime.utcnow().strftime('%Y-%m-%d')
                else:
                    # 이벤트 시간이 없으면 현재 UTC 날짜 사용
                    index_date_str = datetime.utcnow().strftime('%Y-%m-%d')
                index_name = f"web-{index_date_str}" # 최종 인덱스 이름

                # Bulk API 메타데이터 라인 (index 액션 지정)
                bulk_payload_lines.append(json.dumps({"index": {"_index": index_name}}))
                # 실제 로그 레코드 라인 (JSON 문자열)
                bulk_payload_lines.append(json.dumps(record))
            except Exception as e:
                # 개별 레코드 처리 중 오류 발생 시 로깅 (오류 레코드는 건너뜀)
                logger.error(f"Error processing individual record: {e}. Record: {json.dumps(record)}")

        # 리스트의 모든 라인을 개행문자(\n)로 결합하고, 마지막에 개행문자 추가
        final_bulk_data = '\n'.join(bulk_payload_lines) + '\n'
        # --- 여기까지 페이로드 생성 ---

        # --- OpenSearch로 데이터 전송 ---
        # OpenSearch Bulk API 엔드포인트 URL
        url = f"https://{opensearch_endpoint}/_bulk"
        # 요청 헤더 (Content-Type 지정)
        headers = {"Content-Type": "application/x-ndjson"}

        # requests 라이브러리와 SigV4 인증을 사용하여 POST 요청 전송
        r = requests.post(url, auth=aws_auth, data=final_bulk_data.encode('utf-8'), headers=headers)

        logger.info(f"OpenSearch response status: {r.status_code}")

        # OpenSearch 응답 처리 및 로깅
        if r.status_code >= 300:
            # 요청 실패 시 오류 로깅
            logger.error(f"OpenSearch request failed with status {r.status_code}: {r.text}")
            # 실패 응답 본문 로깅 시도 (JSON 형태일 경우)
            try:
                logger.error(f"Failed response body: {r.json()}")
            except json.JSONDecodeError:
                # JSON이 아닌 경우 텍스트 그대로 로깅
                logger.error(f"Failed response body (non-JSON): {r.text}")

        # 성공/실패 여부와 관계없이 응답 본문 처리 시도 (Bulk API는 부분 성공/실패 가능)
        try:
            response_json = r.json()
            # 응답에 'errors' 필드가 true이면 개별 항목 오류 로깅
            if response_json.get('errors'):
                error_count = 0
                logger.warning("Errors reported by OpenSearch Bulk API:")
                for item in response_json.get('items', []):
                    # 각 항목의 'index' 액션 결과 확인
                    if 'error' in item.get('index', {}):
                        error_count += 1
                        # 처음 몇 개의 오류만 상세 로깅
                        if error_count < 10:
                            logger.warning(f"  Item Error: {item['index']['error']}")
                if error_count >= 10:
                    logger.warning(f"  ... and {error_count - 9} more errors.")
        except json.JSONDecodeError:
            # 응답 본문이 JSON이 아닌 경우 (예: 400 Bad Request)
            # 성공 응답(2xx)인데 JSON 파싱 실패한 경우만 로깅 (비정상 상황)
            if r.status_code < 300 :
                logger.error(f"Could not decode JSON from successful response: {r.text}")

        # 최종 함수 종료 로그 (성공/실패 상태 코드 포함)
        logger.info(f"Attempted to process {key} and send {len(records)} records. Final OpenSearch status: {r.status_code}")

        # OpenSearch 요청 성공 여부에 따라 최종 Lambda 응답 결정
        if r.status_code < 300 and not response_json.get('errors'): # 전체 성공 시
            return {'statusCode': 200, 'body': json.dumps('Successfully processed logs.')}
        elif r.status_code < 300 and response_json.get('errors'): # 부분 성공/실패 시
             return {'statusCode': 207, 'body': json.dumps('Processed logs with some errors reported by OpenSearch.')}
        else: # 완전 실패 시
            return {'statusCode': 500, 'body': json.dumps(f'Failed to send logs to OpenSearch. Status: {r.status_code}')}

    # 파일 처리 중 발생 가능한 예외 처리
    except json.JSONDecodeError as e:
        # S3에서 읽은 파일 내용이 유효한 JSON이 아닐 경우
        logger.error(f"Error decoding JSON from file {key}: {e}")
        return {'statusCode': 400, 'body': json.dumps('Invalid JSON format in log file.')}
    except Exception as e:
        # 그 외 예상치 못한 오류 발생 시
        logger.error(f"Error processing file {key} from bucket {bucket}: {e}", exc_info=True) # 스택 트레이스 포함 로깅
        # 오류를 다시 발생시켜 Lambda 재시도 로직 등이 동작하도록 할 수 있음
        raise e

EOF
  }
}

# 5. Lambda 함수 리소스 정의 (Layer 적용)
resource "aws_lambda_function" "s3_to_web_lambda" {
  filename         = data.archive_file.lambda_s3_web_zip.output_path
  source_code_hash = data.archive_file.lambda_s3_web_zip.output_base64sha256 
  function_name = "s3-to-opensearch-web"
  role          = aws_iam_role.lambda_s3_opensearch_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  timeout       = 300
  memory_size   = 256
  environment {
    variables = {
      OPENSEARCH_ENDPOINT = aws_opensearch_domain.log_domain.endpoint
    }
  }
  layers = [aws_lambda_layer_version.opensearch_libs_layer.arn]
  tags = var.tags
}

# --- Lambda 함수 호출 권한 및 S3 이벤트 트리거 설정 ---
# (이전과 동일)
resource "aws_lambda_permission" "allow_s3_invocation_web" {
  statement_id  = "AllowS3InvokeFunction"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_to_web_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.web_bucket.arn
  source_account = data.aws_caller_identity.current.account_id
}
resource "aws_s3_bucket_notification" "web_bucket_notification" {
  # bucket = aws_s3_bucket.cloudtrail_bucket.id
  bucket = data.aws_s3_bucket.web_bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_to_web_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
    filter_prefix     = "WebApp_logs/"
  }
  depends_on = [aws_lambda_permission.allow_s3_invocation_web]
}
