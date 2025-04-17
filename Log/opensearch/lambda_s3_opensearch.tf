# lambda_s3_opensearch.tf

# --- Lambda 함수 실행을 위한 IAM 역할 및 정책 ---

# 1. Lambda 함수가 맡을(assume) IAM 역할 정의
resource "aws_iam_role" "lambda_s3_opensearch_role" {
  name = "lambda-s3-opensearch-role" # 역할 이름

  # Lambda 서비스가 이 역할을 맡을 수 있도록 신뢰 정책 설정
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags # 공통 태그 적용 (variables.tf 에서 정의)
}

# 2. Lambda 함수에 필요한 권한을 정의하는 IAM 정책 생성
resource "aws_iam_policy" "lambda_s3_opensearch_policy" {
  name        = "lambda-s3-opensearch-policy" # 정책 이름
  description = "Policy for Lambda to read CloudTrail logs from S3 and write to OpenSearch"

  # 정책 내용 (JSON 형식)
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # CloudWatch Logs 쓰기 권한 (Lambda 실행 로그 기록용)
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*" # 모든 로그 리소스에 허용 (필요시 더 제한 가능)
      },
      {
        # S3 버킷 읽기 권한 (CloudTrail 로그 파일 접근용)
        Action = [
          "s3:GetObject", # 객체 다운로드
          "s3:ListBucket" # 버킷 내용 리스팅 (필요할 수 있음)
        ]
        Effect   = "Allow"
        # 중요: 대상 S3 버킷 및 객체 경로를 정확히 지정
        Resource = [
          aws_s3_bucket.cloudtrail_bucket.arn,       # 버킷 자체 ARN
          "${aws_s3_bucket.cloudtrail_bucket.arn}/*" # 버킷 내 모든 객체 ARN
        ]
        # aws_s3_bucket.cloudtrail_bucket 리소스는 cloudtrail.tf 에 정의되어 있어야 함
      },
      {
        # OpenSearch 도메인 쓰기 권한 (로그 데이터 전송용)
        Action = [
          "es:ESHttpPost", # OpenSearch Bulk API 등 데이터 전송에 필요
          "es:ESHttpPut",
          "es:ESHttpGet" # 필요에 따라 추가 (예: 클러스터 상태 확인 등)
        ]
        Effect   = "Allow"
        # 중요: 대상 OpenSearch 도메인 ARN을 정확히 지정
        Resource = "${aws_opensearch_domain.log_domain.arn}/*"
        # aws_opensearch_domain.log_domain 리소스는 opensearch.tf 에 정의되어 있어야 함
      }
    ]
  })
}

# 3. 생성한 IAM 정책을 Lambda 실행 역할에 연결(attach)
resource "aws_iam_role_policy_attachment" "lambda_s3_opensearch_attach" {
  role       = aws_iam_role.lambda_s3_opensearch_role.name # 연결할 역할 이름
  policy_arn = aws_iam_policy.lambda_s3_opensearch_policy.arn # 연결할 정책 ARN
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
    # 인라인 Python 코드 내용 (Layer 라이브러리 사용 및 SigV4 서명 적용)
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
# 현재 리전 가져오기 (SigV4 서명에 필요)
aws_region = os.environ.get('AWS_REGION', 'ap-northeast-2') # Lambda 환경 변수에서 가져오거나 기본값 사용

# --- SigV4 인증 설정 ---
# Lambda 실행 역할의 자격 증명을 자동으로 사용
credentials = boto3.Session().get_credentials()
aws_auth = AWSRequestsAuth(aws_access_key=credentials.access_key,
                           aws_secret_access_key=credentials.secret_key,
                           aws_token=credentials.token, # 임시 자격 증명 토큰 포함
                           aws_host=opensearch_endpoint,
                           aws_region=aws_region,
                           aws_service='es') # OpenSearch 서비스 이름 'es'

def lambda_handler(event, context):
    logger.info("Received event: " + json.dumps(event, indent=2))

    # S3 이벤트에서 버킷 이름과 파일 키 가져오기
    try:
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']
        # URL-encoded 키 디코딩 (공백 등 특수 문자 처리)
        key = key.replace('+', ' ')
    except (KeyError, IndexError) as e:
        logger.error(f"Could not extract bucket/key from event: {e}")
        return {'statusCode': 400, 'body': json.dumps('Invalid S3 event format')}

    # --- 안정성을 위해 try-except 블록 복구 ---
    try:
        # S3에서 로그 파일 다운로드
        response = s3.get_object(Bucket=bucket, Key=key)
        content = response['Body'].read()

        # 압축 해제 (.gz)
        log_data_raw = gzip.decompress(content).decode('utf-8')
        log_data = json.loads(log_data_raw)

        records = log_data.get('Records', [])
        logger.info(f"Processing {len(records)} records from {key}")

        if not records:
            logger.info("No records to send.")
            return {'statusCode': 200, 'body': json.dumps('No records found in the file.')}

        # OpenSearch Bulk API 형식으로 데이터 준비
        bulk_data = ""
        for record in records:
            try:
                # 인덱스 이름 생성 (예: cloudtrail-YYYY-MM-DD)
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

                index_name = f"cloudtrail-{index_date_str}" # 날짜 기반 인덱스

                # Bulk API 메타데이터 라인
                bulk_data += json.dumps({"index": {"_index": index_name}}) + "\\n"
                # 실제 로그 레코드 라인
                bulk_data += json.dumps(record) + "\\n"
            except Exception as e:
                logger.error(f"Error processing individual record: {e}. Record: {json.dumps(record)}")

        # OpenSearch로 데이터 전송 (requests 및 SigV4 사용)
        url = f"https://{opensearch_endpoint}/_bulk"
        headers = {"Content-Type": "application/x-ndjson"}

        # 'requests' 라이브러리 사용 및 aws_auth 로 SigV4 서명 적용
        r = requests.post(url, auth=aws_auth, data=bulk_data.encode('utf-8'), headers=headers)

        logger.info(f"OpenSearch response status: {r.status_code}")
        # logger.debug(f"OpenSearch response body: {r.text}") # 상세 응답 필요 시 DEBUG 레벨 사용

        # 응답 내용 확인 (오류 확인 등)
        if r.status_code >= 300:
             logger.error(f"OpenSearch request failed with status {r.status_code}: {r.text}")

        response_json = r.json() # requests 는 json() 메소드 제공
        if response_json.get('errors'):
            error_count = 0
            logger.warning("Errors reported by OpenSearch Bulk API:")
            # 오류 상세 로깅 (샘플)
            for item in response_json.get('items', []):
                if 'error' in item.get('index', {}):
                     error_count += 1
                     # 로그가 너무 길어지는 것을 방지하기 위해 일부 오류만 로깅할 수 있음
                     if error_count < 10:
                        logger.warning(f"  Item Error: {item['index']['error']}")
            if error_count >= 10:
                logger.warning(f"  ... and {error_count - 9} more errors.")


        logger.info(f"Successfully processed {key} and attempted to send {len(records)} records.")
        return {'statusCode': 200, 'body': json.dumps('Successfully processed logs.')}

    except json.JSONDecodeError as e:
        logger.error(f"Error decoding JSON from file {key}: {e}")
        # JSON 파싱 오류 시 재시도하지 않도록 처리 가능
        return {'statusCode': 400, 'body': json.dumps('Invalid JSON format in log file.')}
    except Exception as e:
        logger.error(f"Error processing file {key} from bucket {bucket}: {e}", exc_info=True)
        raise e # 그 외 오류 발생 시 Lambda 재시도 유도
    # --- 여기까지 try-except 블록 ---

EOF
  }
}

# 5. Lambda 함수 리소스 정의 (Layer 적용)
resource "aws_lambda_function" "s3_to_opensearch_lambda" {
  # 함수 코드 zip 파일 참조
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  function_name = "s3-to-opensearch-cloudtrail" # Lambda 함수 이름
  role          = aws_iam_role.lambda_s3_opensearch_role.arn # 위에서 정의한 IAM 역할 연결
  handler       = "index.lambda_handler" # source 블록의 filename.함수명
  runtime       = "python3.9" # 사용할 Python 런타임 버전
  timeout       = 300 # 함수 최대 실행 시간 (초)
  memory_size   = 256 # 함수에 할당할 메모리 (MB)

  environment {
    variables = {
      # OpenSearch 엔드포인트를 Lambda 환경 변수로 전달
      OPENSEARCH_ENDPOINT = aws_opensearch_domain.log_domain.endpoint
      # aws_opensearch_domain.log_domain 리소스는 opensearch.tf 에 정의되어 있어야 함
      # AWS_REGION 환경 변수는 Lambda 실행 환경에 자동으로 설정되는 경우가 많음
      # AWS_REGION = var.aws_region
    }
  }

  # --- 추가된 부분: 생성한 Lambda Layer 연결 ---
  # aws_lambda_layer_version.opensearch_libs_layer 리소스는 lambda_layer.tf 에 정의되어 있어야 함
  layers = [aws_lambda_layer_version.opensearch_libs_layer.arn]
  # --- 여기까지 ---

  tags = var.tags # 공통 태그 적용
}

# --- Lambda 함수 호출 권한 및 S3 이벤트 트리거 설정 ---

# 6. S3 서비스가 Lambda 함수를 호출할 수 있도록 권한 부여
resource "aws_lambda_permission" "allow_s3_invocation" {
  statement_id  = "AllowS3InvokeFunction" # 권한 문 ID
  action        = "lambda:InvokeFunction" # 허용할 액션
  function_name = aws_lambda_function.s3_to_opensearch_lambda.function_name # 대상 Lambda 함수
  principal     = "s3.amazonaws.com" # 호출 주체 (S3 서비스)
  # 중요: S3 버킷 소유자 계정 ID와 버킷 ARN을 정확히 지정
  source_arn    = aws_s3_bucket.cloudtrail_bucket.arn # 이벤트를 발생시키는 S3 버킷 ARN
  source_account = data.aws_caller_identity.current.account_id # 버킷 소유자 계정 ID
  # data.aws_caller_identity.current 는 providers.tf 등에 정의되어 있어야 함
}

# 7. S3 버킷 알림 설정 (객체 생성 시 Lambda 함수 트리거)
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id # 알림을 설정할 S3 버킷 ID

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_to_opensearch_lambda.arn # 트리거할 Lambda 함수 ARN
    events              = ["s3:ObjectCreated:*"] # 모든 객체 생성 이벤트 감지
    filter_suffix       = ".gz" # .gz 확장자로 끝나는 객체만 트리거
    # CloudTrail 기본 경로 하위 파일만 트리거하려면 아래 주석 해제 및 계정 ID 확인
    # filter_prefix     = "AWSLogs/${data.aws_caller_identity.current.account_id}/"
  }

  # aws_lambda_permission 리소스가 먼저 생성되도록 의존성 추가
  depends_on = [aws_lambda_permission.allow_s3_invocation]
}
