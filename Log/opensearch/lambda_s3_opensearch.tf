# lambda_s3_opensearch.tf

# --- Lambda 함수 실행을 위한 IAM 역할 및 정책 ---
# (IAM 역할, 정책, 정책 연결 부분은 이전과 동일)
resource "aws_iam_role" "lambda_s3_opensearch_role" {
  name = "lambda-s3-opensearch-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [ { Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } } ]
  })
  tags = var.tags
}
resource "aws_iam_policy" "lambda_s3_opensearch_policy" {
  name        = "lambda-s3-opensearch-policy"
  description = "Policy for Lambda to read CloudTrail logs from S3 and write to OpenSearch"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Effect = "Allow", Resource = "arn:aws:logs:*:*:*" },
      { Action = ["s3:GetObject", "s3:ListBucket"], Effect = "Allow", Resource = [ aws_s3_bucket.cloudtrail_bucket.arn, "${aws_s3_bucket.cloudtrail_bucket.arn}/*" ] },
      { Action = ["es:ESHttpPost", "es:ESHttpPut", "es:ESHttpGet"], Effect = "Allow", Resource = "${aws_opensearch_domain.log_domain.arn}/*" }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_s3_opensearch_attach" {
  role       = aws_iam_role.lambda_s3_opensearch_role.name
  policy_arn = aws_iam_policy.lambda_s3_opensearch_policy.arn
}

# --- Lambda 함수 정의 ---

# 4. Lambda 함수 코드 자체를 포함하는 zip 아카이브 생성
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function_payload.zip" # 임시 zip 파일 경로

  # source 블록을 사용하여 인라인 코드 제공
  source {
    # zip 파일 내에서 사용될 파일 이름 (Lambda 핸들러와 일치해야 함: index.py)
    filename = "index.py"
    # 인라인 Python 코드 내용 (Bulk 데이터 생성 방식 수정)
    content = <<-EOF
import json
import boto3
import gzip
import os
import requests # Layer 에 포함된 라이브러리 import
from aws_requests_auth.aws_auth import AWSRequestsAuth # Layer 에 포함된 라이브러리 import
from datetime import datetime
import logging

# 로깅 설정
logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')
opensearch_endpoint = os.environ['OPENSEARCH_ENDPOINT']
aws_region = os.environ.get('AWS_REGION', 'ap-northeast-2')

# SigV4 인증 설정
credentials = boto3.Session().get_credentials()
aws_auth = AWSRequestsAuth(aws_access_key=credentials.access_key,
                           aws_secret_access_key=credentials.secret_key,
                           aws_token=credentials.token,
                           aws_host=opensearch_endpoint,
                           aws_region=aws_region,
                           aws_service='es')

def lambda_handler(event, context):
    logger.info("Received event: " + json.dumps(event, indent=2))

    try:
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']
        key = key.replace('+', ' ')
    except (KeyError, IndexError) as e:
        logger.error(f"Could not extract bucket/key from event: {e}")
        return {'statusCode': 400, 'body': json.dumps('Invalid S3 event format')}

    try:
        response = s3.get_object(Bucket=bucket, Key=key)
        content = response['Body'].read()
        log_data_raw = gzip.decompress(content).decode('utf-8')
        log_data = json.loads(log_data_raw)
        records = log_data.get('Records', [])
        logger.info(f"Processing {len(records)} records from {key}")

        if not records:
            logger.info("No records to send.")
            return {'statusCode': 200, 'body': json.dumps('No records found in the file.')}

        # --- 수정된 부분: Bulk 데이터 생성 방식 변경 ---
        bulk_payload_lines = [] # 각 라인을 저장할 리스트 생성
        for record in records:
            try:
                event_time_str = record.get('eventTime')
                if event_time_str:
                    try:
                        dt_obj = datetime.fromisoformat(event_time_str.replace('Z', '+00:00'))
                        index_date_str = dt_obj.strftime('%Y-%m-%d')
                    except ValueError:
                        logger.warning(f"Could not parse eventTime '{event_time_str}', using current date.")
                        index_date_str = datetime.utcnow().strftime('%Y-%m-%d')
                else:
                    index_date_str = datetime.utcnow().strftime('%Y-%m-%d')
                index_name = f"cloudtrail-{index_date_str}"

                # Bulk API 메타데이터 라인 추가
                bulk_payload_lines.append(json.dumps({"index": {"_index": index_name}}))
                # 실제 로그 레코드 라인 추가
                bulk_payload_lines.append(json.dumps(record))
            except Exception as e:
                logger.error(f"Error processing individual record: {e}. Record: {json.dumps(record)}")

        # 리스트의 모든 라인을 개행문자(\n)로 합치고, 맨 마지막에 개행문자 추가
        final_bulk_data = '\n'.join(bulk_payload_lines) + '\n'
        # --- 여기까지 수정 ---

        # OpenSearch로 데이터 전송 (requests 및 SigV4 사용)
        url = f"https://{opensearch_endpoint}/_bulk"
        headers = {"Content-Type": "application/x-ndjson"}

        # 수정된 final_bulk_data 사용
        r = requests.post(url, auth=aws_auth, data=final_bulk_data.encode('utf-8'), headers=headers)

        logger.info(f"OpenSearch response status: {r.status_code}")

        if r.status_code >= 300:
             logger.error(f"OpenSearch request failed with status {r.status_code}: {r.text}")
             # 오류 발생 시에도 응답 본문 로깅 시도 (오류 상세 확인용)
             try:
                 logger.error(f"Failed response body: {r.json()}")
             except json.JSONDecodeError:
                 logger.error(f"Failed response body (non-JSON): {r.text}")


        # 성공/실패 여부와 관계없이 응답 본문 처리 시도
        try:
            response_json = r.json()
            if response_json.get('errors'):
                error_count = 0
                logger.warning("Errors reported by OpenSearch Bulk API:")
                for item in response_json.get('items', []):
                    if 'error' in item.get('index', {}):
                         error_count += 1
                         if error_count < 10:
                            logger.warning(f"  Item Error: {item['index']['error']}")
                if error_count >= 10:
                    logger.warning(f"  ... and {error_count - 9} more errors.")
        except json.JSONDecodeError:
            # 400 Bad Request 등 에러 시 응답 본문이 JSON이 아닐 수 있음
             if r.status_code < 300 : # 성공 응답인데 JSON 파싱 실패한 경우만 로깅
                 logger.error(f"Could not decode JSON from successful response: {r.text}")


        # 함수 종료 로그는 요청 시도 후 상태와 관계없이 기록될 수 있음
        logger.info(f"Successfully processed {key} and attempted to send {len(records)} records. Final status: {r.status_code}")
        # 실제 성공 여부는 status_code 로 판단하는 것이 더 정확
        if r.status_code < 300:
             return {'statusCode': 200, 'body': json.dumps('Successfully processed logs.')}
        else:
             # 실패 시 오류 상태 코드 반환 고려
             return {'statusCode': 500, 'body': json.dumps(f'Failed to send logs to OpenSearch. Status: {r.status_code}')}


    except json.JSONDecodeError as e:
        logger.error(f"Error decoding JSON from file {key}: {e}")
        return {'statusCode': 400, 'body': json.dumps('Invalid JSON format in log file.')}
    except Exception as e:
        logger.error(f"Error processing file {key} from bucket {bucket}: {e}", exc_info=True)
        raise e

EOF
  }
}

# 5. Lambda 함수 리소스 정의 (Layer 적용)
resource "aws_lambda_function" "s3_to_opensearch_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name = "s3-to-opensearch-cloudtrail"
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
resource "aws_lambda_permission" "allow_s3_invocation" {
  statement_id  = "AllowS3InvokeFunction"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_to_opensearch_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.cloudtrail_bucket.arn
  source_account = data.aws_caller_identity.current.account_id
}
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_to_opensearch_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".gz"
    # filter_prefix     = "AWSLogs/${data.aws_caller_identity.current.account_id}/"
  }
  depends_on = [aws_lambda_permission.allow_s3_invocation]
}
