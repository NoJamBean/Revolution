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
import geoip2.database 
import shutil  

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')

# --- 환경 변수 ---
opensearch_endpoint = os.environ['OPENSEARCH_ENDPOINT']
aws_region = os.environ.get('AWS_REGION', 'ap-northeast-2')
geoip_db_bucket = os.environ.get('GEOIP_DB_BUCKET', "tfstate-bucket-revolution112233") # 기본값 또는 환경변수 필요
geoip_db_key = os.environ.get('GEOIP_DB_KEY', "mmdb/GeoLite2-City.mmdb") # 기본값 또는 환경변수 필요
geoip_db_local_path = '/tmp/GeoLite2-City.mmdb' # Lambda 임시 저장 경로

# --- OpenSearch 인증 설정 (기존과 동일) ---
try:
    credentials = boto3.Session().get_credentials()
    aws_auth = AWSRequestsAuth(aws_access_key=credentials.access_key,
                               aws_secret_access_key=credentials.secret_key,
                               aws_token=credentials.token,
                               aws_host=opensearch_endpoint,
                               aws_region=aws_region,
                               aws_service='es') # OpenSearch Service의 서비스 이름은 'es'
except Exception as e:
    logger.error(f"Failed to get AWS credentials or initialize AWSRequestsAuth: {e}", exc_info=True)
    # 인증 실패 시 심각한 문제이므로 초기 단계에서 처리 필요 가능성
    aws_auth = None # 인증 객체 생성 실패

# --- GeoIP Reader 초기화 (Lambda 실행 컨텍스트 재사용 고려) ---
geoip_reader = None # 초기화 전 None으로 설정

# /tmp에 파일이 없으면 S3에서 다운로드 시도
if not os.path.exists(geoip_db_local_path):
    logger.info(f"GeoIP DB not found locally. Attempting download from s3://{geoip_db_bucket}/{geoip_db_key} to {geoip_db_local_path}")
    try:
        # 임시 파일 경로 생성
        tmp_download_path = geoip_db_local_path + ".tmp"
        # 디렉토리가 없을 경우 생성
        os.makedirs(os.path.dirname(geoip_db_local_path), exist_ok=True)
        s3.download_file(geoip_db_bucket, geoip_db_key, tmp_download_path)
        # 다운로드 성공 시 최종 경로로 이동 (원자성 확보)
        shutil.move(tmp_download_path, geoip_db_local_path)
        logger.info("GeoIP DB downloaded successfully.")
    except Exception as e:
        logger.error(f"Failed to download GeoIP DB from s3://{geoip_db_bucket}/{geoip_db_key}: {e}", exc_info=True)
        # 다운로드 실패 시 geoip_reader는 None으로 유지됨
else:
    logger.info(f"Using cached GeoIP DB from {geoip_db_local_path}.")

# GeoIP Reader 객체 생성 시도 (파일이 성공적으로 준비되었을 경우)
if os.path.exists(geoip_db_local_path):
    try:
        # 이 객체는 Lambda 컨테이너가 살아있는 동안 재사용될 수 있음
        geoip_reader = geoip2.database.Reader(geoip_db_local_path)
        logger.info("GeoIP Reader initialized successfully.")
    except Exception as e:
        logger.error(f"Failed to initialize GeoIP Reader from {geoip_db_local_path}: {e}", exc_info=True)
        geoip_reader = None # 리더 초기화 실패 시 None으로 설정
else:
     logger.warning("GeoIP DB file does not exist locally. GeoIP lookups will be skipped.")


def get_geoip_info(ip_address):
    """주어진 IP 주소에 대한 GeoIP 정보를 조회합니다."""
    # geoip_reader가 성공적으로 초기화되지 않았거나 IP 주소가 없으면 None 반환
    if not geoip_reader or not ip_address:
        return None

    try:
        # IP 주소로 도시 정보 조회
        response = geoip_reader.city(ip_address)
        geoip_data = {
            # 국가 정보 (ISO 코드 및 이름)
            "country_iso_code": response.country.iso_code,
            "country_name": response.country.name,
            # 도시 이름
            "city_name": response.city.name,
            # 위치 정보 (위도, 경도) - OpenSearch geo_point 형식
            "location": {
                "lat": response.location.latitude,
                "lon": response.location.longitude
            }
            # 필요에 따라 추가 필드 포함 가능:
            # "continent_code": response.continent.code,
            # "postal_code": response.postal.code,
            # "time_zone": response.location.time_zone,
        }
        return geoip_data
    except geoip2.errors.AddressNotFoundError:
        # 데이터베이스에 IP 주소가 없는 경우
        logger.debug(f"IP address not found in GeoIP database: {ip_address}")
        return None
    except Exception as e:
        # 기타 조회 오류 발생 시 경고 로깅
        logger.warning(f"Error looking up GeoIP for {ip_address}: {e}")
        return None

def lambda_handler(event, context):
    logger.info("Received event: " + json.dumps(event, indent=2))

    # OpenSearch 인증 객체 확인
    if not aws_auth:
         logger.error("AWSRequestsAuth is not initialized. Cannot proceed.")
         # 실패 처리 또는 재시도 로직 필요 가능성
         return {'statusCode': 500, 'body': json.dumps('Internal server error: Authentication not configured.')}

    try:
        # S3 이벤트에서 버킷 이름과 객체 키 추출
        bucket = event['Records'][0]['s3']['bucket']['name']
        # URL 인코딩된 '+' 문자를 공백으로 변환 (필요한 경우)
        key = event['Records'][0]['s3']['object']['key'].replace('+', ' ')
    except (KeyError, IndexError, TypeError) as e:
        logger.error(f"Could not extract bucket/key from event: {e}. Event structure might be incorrect.")
        return {'statusCode': 400, 'body': json.dumps('Invalid S3 event format')}

    try:
        # S3에서 로그 파일 객체 가져오기
        response = s3.get_object(Bucket=bucket, Key=key)
        # 파일 내용 읽기
        content = response['Body'].read()
        # UTF-8로 디코딩
        log_data_raw = content.decode('utf-8')
        # JSON 파싱
        log_data = json.loads(log_data_raw)
        # 'Records' 키에서 실제 로그 레코드 리스트 가져오기 (없으면 빈 리스트)
        records = log_data.get('Records', [])
        logger.info(f"Processing {len(records)} records from s3://{bucket}/{key}")

        # 처리할 레코드가 없으면 성공 응답 반환
        if not records:
            logger.info("No records to send.")
            return {'statusCode': 200, 'body': json.dumps('No records found in the file.')}

        bulk_payload_lines = [] # OpenSearch Bulk API 요청 본문을 위한 리스트
        processed_count = 0
        skipped_geoip_count = 0

        # 각 로그 레코드 처리
        for record in records:
            try:
                # --- GeoIP 정보 추가 로직 ---
                source_ip = record.get('sourceIPAddress')
                if source_ip:
                    # 정의된 함수를 사용하여 GeoIP 정보 조회
                    geoip_info = get_geoip_info(source_ip)
                    if geoip_info:
                        # 조회된 정보가 있으면 원본 레코드에 'geoip' 필드로 추가
                        record['geoip'] = geoip_info
                    else:
                        # GeoIP 조회 실패 또는 정보 없음 (로그 기록은 get_geoip_info 내부에서 처리)
                        skipped_geoip_count += 1
                else:
                    # sourceIPAddress 필드가 없는 경우
                    skipped_geoip_count += 1
                # --------------------------

                # 이벤트 시간 기준으로 인덱스 이름 생성 (기존 로직)
                event_time_str = record.get('eventTime')
                if event_time_str:
                    try:
                        # ISO 8601 형식 파싱 (시간대 정보 포함)
                        dt_obj = datetime.fromisoformat(event_time_str.replace('Z', '+00:00'))
                        index_date_str = dt_obj.strftime('%Y-%m-%d')
                    except ValueError:
                        # 파싱 실패 시 현재 UTC 날짜 사용 및 경고 로깅
                        logger.warning(f"Could not parse eventTime '{event_time_str}', using current date.")
                        index_date_str = datetime.utcnow().strftime('%Y-%m-%d')
                else:
                    # eventTime 필드가 없으면 현재 UTC 날짜 사용
                    index_date_str = datetime.utcnow().strftime('%Y-%m-%d')
                # 최종 인덱스 이름 생성 (예: web-2025-04-23)
                index_name = f"web-{index_date_str}"

                # OpenSearch Bulk API 액션 메타데이터 추가 (인덱스 지정)
                bulk_payload_lines.append(json.dumps({"index": {"_index": index_name}}))
                # 수정된 로그 레코드 추가 (GeoIP 정보 포함 가능)
                bulk_payload_lines.append(json.dumps(record))
                processed_count += 1

            except Exception as e:
                # 개별 레코드 처리 중 오류 발생 시 로깅
                logger.error(f"Error processing individual record: {e}. Record: {json.dumps(record)}", exc_info=True)

        # 처리된 레코드가 있을 경우에만 OpenSearch로 전송
        if not bulk_payload_lines:
             logger.info("No records were successfully processed to be sent.")
             return {'statusCode': 200, 'body': json.dumps('No processable records found.')}

        # Bulk API 요청 본문 생성 (각 라인은 개행 문자로 구분)
        final_bulk_data = '\n'.join(bulk_payload_lines) + '\n'

        # OpenSearch Bulk API 엔드포인트 URL
        url = f"https://{opensearch_endpoint}/_bulk"
        # 요청 헤더 설정 (NDJSON 형식 명시)
        headers = {"Content-Type": "application/x-ndjson"}

        logger.info(f"Sending {processed_count} records ({skipped_geoip_count} skipped GeoIP) to OpenSearch index pattern 'web-*'...")

        # OpenSearch Bulk API 요청 실행
        r = requests.post(url, auth=aws_auth, data=final_bulk_data.encode('utf-8'), headers=headers, timeout=60) # 타임아웃 설정

        logger.info(f"OpenSearch response status: {r.status_code}")

        # --- 응답 처리 (기존 로직과 유사하게 유지) ---
        response_json = {} # 초기화
        errors_occurred = False

        # 응답 상태 코드가 300 이상이면 오류 로깅
        if r.status_code >= 300:
            logger.error(f"OpenSearch request failed with status {r.status_code}.")
            try:
                 # 오류 응답 본문을 JSON으로 파싱 시도 및 로깅
                response_json = r.json()
                logger.error(f"Failed response body: {json.dumps(response_json)}")
            except json.JSONDecodeError:
                 # JSON 파싱 실패 시 텍스트로 로깅
                logger.error(f"Failed response body (non-JSON): {r.text}")
            errors_occurred = True # 실패로 간주
        else:
            # 성공 응답(2xx)의 경우 JSON 파싱 시도
             try:
                 response_json = r.json()
                 # 응답 본문에 'errors' 필드가 true이면 개별 항목 오류 확인
                 if isinstance(response_json, dict) and response_json.get('errors'):
                     errors_occurred = True
                     error_count = 0
                     logger.warning("Errors reported by OpenSearch Bulk API:")
                     # 각 항목의 오류 정보 로깅 (최대 10개)
                     for item in response_json.get('items', []):
                         action_result = item.get('index') or item.get('create') or item.get('update') or item.get('delete') # 다양한 액션 고려
                         if action_result and 'error' in action_result:
                             error_count += 1
                             if error_count < 10:
                                  logger.warning(f"  Item Error: {action_result['error']}")
                     if error_count >= 10:
                         logger.warning(f"  ... and {error_count - 9} more errors.")

             except json.JSONDecodeError:
                  # 성공 응답이지만 JSON 파싱 실패 시 로깅
                  logger.error(f"Could not decode JSON from successful response: {r.text}")

        logger.info(f"Finished processing s3://{bucket}/{key}. Sent {processed_count} records. Final OpenSearch status: {r.status_code}. Errors reported: {errors_occurred}")

        # 최종 상태에 따른 응답 반환
        if r.status_code < 300 and not errors_occurred: # 전체 성공
            return {'statusCode': 200, 'body': json.dumps('Successfully processed logs.')}
        elif r.status_code < 300 and errors_occurred: # 부분 성공/실패
             return {'statusCode': 207, 'body': json.dumps('Processed logs with some errors reported by OpenSearch.')}
        else: # 완전 실패
            return {'statusCode': r.status_code, 'body': json.dumps(f'Failed to send logs to OpenSearch. Status: {r.status_code}')}

    except json.JSONDecodeError as e:
        # 입력 파일의 JSON 형식 오류
        logger.error(f"Error decoding JSON from file s3://{bucket}/{key}: {e}")
        return {'statusCode': 400, 'body': json.dumps('Invalid JSON format in log file.')}
    except Exception as e:
        # 기타 예외 처리
        logger.error(f"Error processing file s3://{bucket}/{key}: {e}", exc_info=True) # 스택 트레이스 포함 로깅
        # 오류 발생 시 Lambda가 재시도하도록 예외를 다시 발생시킬 수 있음
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
      GEOIP_DB_BUCKET     = "tfstate-bucket-revolution112233"
      GEOIP_DB_KEY        = "mmdb/GeoLite2-City.mmdb" 
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
