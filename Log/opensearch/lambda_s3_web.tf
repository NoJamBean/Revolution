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
from aws_requests_auth.aws_auth import AWSRequestsAuth 
from datetime import datetime
import logging
import geoip2.database 

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')

opensearch_endpoint = os.environ['OPENSEARCH_ENDPOINT']
aws_region = os.environ.get('AWS_REGION', 'ap-northeast-2') # 기본값 설정

credentials = boto3.Session().get_credentials()
aws_auth = AWSRequestsAuth(aws_access_key=credentials.access_key,
                           aws_secret_access_key=credentials.secret_key,
                           aws_token=credentials.token,
                           aws_host=opensearch_endpoint.replace('https://',''), # 호스트명만 전달
                           aws_region=aws_region,
                           aws_service='es') # OpenSearch Service의 서비스 이름은 'es'

db_path = os.environ.get('GEOIP_DB_PATH', '/opt/GeoLite2-City.mmdb')
reader = None
try:
    logger.info(f"Attempting to load GeoIP database from: {db_path}")
    reader = geoip2.database.Reader(db_path)
    logger.info("GeoIP database loaded successfully.")
except FileNotFoundError:
    logger.error(f"CRITICAL: GeoIP Database not found at {db_path}. GeoIP enrichment will be disabled.")
except Exception as e:
    logger.error(f"CRITICAL: Failed to load GeoIP database from {db_path}: {e}. GeoIP enrichment will be disabled.")

def lambda_handler(event, context):
    global reader # 전역 변수 reader 사용 명시

    logger.info("Received event: " + json.dumps(event, indent=2))

    try:
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key'].replace('+', ' ')
        logger.info(f"Processing object {key} from bucket {bucket}")

    except (KeyError, IndexError, TypeError) as e:
        logger.error(f"Could not extract bucket/key from event: {e}. Event structure might be incorrect.")
        return {'statusCode': 400, 'body': json.dumps('Invalid S3 event format')}

    try:
        response = s3.get_object(Bucket=bucket, Key=key)
        content = response['Body'].read()
        log_data_raw = content.decode('utf-8')

        log_data = json.loads(log_data_raw)
        records = log_data.get('Records', []) # 제공된 예시 형식이므로 'Records' 키 사용
        logger.info(f"Processing {len(records)} records from {key}")

        if not records:
            logger.info("No records to send.")
            return {'statusCode': 200, 'body': json.dumps('No records found in the file.')}

        bulk_payload_lines = [] # 벌크 요청 본문을 위한 라인 리스트
        processed_count = 0
        for record in records:
            try:
                ip_address = record.get('sourceIPAddress')
                if ip_address and reader: # IP 주소가 있고, DB 로더가 성공적으로 초기화되었을 때만 시도
                    try:
                        geo_response = reader.city(ip_address) # IP 조회
                        geo_info = {}

                        if geo_response.country.iso_code:
                            geo_info['country_iso_code'] = geo_response.country.iso_code
                        if geo_response.country.name:
                            geo_info['country_name'] = geo_response.country.name
                        if geo_response.subdivisions.most_specific.name:
                             geo_info['subdivision_name'] = geo_response.subdivisions.most_specific.name
                        if geo_response.city.name:
                            geo_info['city_name'] = geo_response.city.name
                        if geo_response.postal.code:
                             geo_info['postal_code'] = geo_response.postal.code
                        if geo_response.location.latitude and geo_response.location.longitude:
                            # OpenSearch geo_point 형식
                            geo_info['location'] = {
                                'lat': geo_response.location.latitude,
                                'lon': geo_response.location.longitude
                            }

                        if geo_info:
                            record['geoip'] = geo_info
                            # logger.debug(f"Added GeoIP for {ip_address}: {json.dumps(geo_info)}") # 디버깅 시 유용

                    except geoip2.errors.AddressNotFoundError:
                        logger.debug(f"IP address not found in GeoIP database: {ip_address}")
                    except ValueError:
                        logger.warning(f"Invalid IP address format for GeoIP lookup: {ip_address}")
                    except Exception as geo_e:
                        logger.error(f"Error during GeoIP lookup for {ip_address}: {geo_e}")
                elif not reader and ip_address:
                    logger.warning(f"GeoIP reader not available, skipping enrichment for IP: {ip_address}")

                event_time_str = record.get('eventTime')
                index_date_str = datetime.utcnow().strftime('%Y-%m-%d') # 기본값: 현재 날짜
                if event_time_str:
                    try:
                        dt_obj = datetime.fromisoformat(event_time_str.replace('Z', '+00:00'))
                        index_date_str = dt_obj.strftime('%Y-%m-%d') # 날짜 부분만 사용
                    except ValueError:
                        logger.warning(f"Could not parse eventTime '{event_time_str}', using current date for index.")
                index_name = f"web-{index_date_str}" # 인덱스 이름 형식 (예: web-YYYY-MM-DD)

                bulk_payload_lines.append(json.dumps({"index": {"_index": index_name}}))
                bulk_payload_lines.append(json.dumps(record))
                processed_count += 1

            except Exception as e:
                logger.error(f"Error processing individual record: {e}. Record (partial): {json.dumps(record, default=str)}")


        if bulk_payload_lines:
            final_bulk_data = '\n'.join(bulk_payload_lines) + '\n'
            url = f"https://{opensearch_endpoint}/_bulk" # 엔드포인트 URL 확인 (https:// 포함)
            headers = {"Content-Type": "application/x-ndjson"}

            logger.info(f"Sending {processed_count} records ({len(bulk_payload_lines)//2} actions) to OpenSearch index pattern 'web-*'...")

            # --- OpenSearch로 벌크 요청 전송 (기존 로직 유지) ---
            r = requests.post(url, auth=aws_auth, data=final_bulk_data.encode('utf-8'), headers=headers, timeout=30) # 타임아웃 추가 권장

            logger.info(f"OpenSearch response status: {r.status_code}")

            # --- 응답 처리 (기존 로직 유지, 일부 로깅 개선) ---
            response_json = None
            try:
                response_json = r.json()
            except json.JSONDecodeError:
                 logger.error(f"Could not decode JSON response from OpenSearch. Status: {r.status_code}, Response text: {r.text[:500]}") # 응답 일부 로깅

            if r.status_code >= 300:
                logger.error(f"OpenSearch bulk request failed. Status: {r.status_code}, Response: {r.text[:1000]}") # 응답 본문 일부 로깅
                # 실패 시 반환 상태 코드 설정
                return {'statusCode': 500, 'body': json.dumps(f'Failed to send logs to OpenSearch. Status: {r.status_code}')}

            # 성공했더라도 개별 항목 오류 확인 (기존 로직 유지)
            if response_json and response_json.get('errors'):
                error_count = 0
                items_with_errors = []
                for item in response_json.get('items', []):
                    action_result = item.get('index', {}) # 'index' 액션 결과 확인
                    if action_result.get('error'):
                        error_count += 1
                        if error_count <= 10: # 너무 많은 오류 로그 방지
                             items_with_errors.append(action_result)
                logger.warning(f"OpenSearch reported {error_count} errors in the bulk response. First {len(items_with_errors)} errors: {json.dumps(items_with_errors)}")
                # 부분 성공/실패 시 상태 코드 207 반환
                return {'statusCode': 207, 'body': json.dumps('Processed logs with some errors reported by OpenSearch.')}
            elif r.status_code < 300:
                 # 전체 성공 시
                 logger.info(f"Successfully sent {processed_count} records to OpenSearch.")
                 return {'statusCode': 200, 'body': json.dumps('Successfully processed logs.')}

        else:
            logger.info("No valid records were processed to be sent.")
            return {'statusCode': 200, 'body': json.dumps('No records were sent to OpenSearch.')}

    except json.JSONDecodeError as e:
        logger.error(f"Error decoding JSON from file {key}: {e}")
        return {'statusCode': 400, 'body': json.dumps('Invalid JSON format in log file.')}
    except ClientError as e: # Boto3 관련 오류 명시적 처리
        if e.response['Error']['Code'] == 'NoSuchKey':
             logger.error(f"S3 object {key} not found in bucket {bucket}. It might have been deleted before processing.")
             return {'statusCode': 404, 'body': json.dumps('S3 object not found.')}
        else:
             logger.error(f"Boto3 client error processing file {key}: {e}", exc_info=True)
             return {'statusCode': 500, 'body': json.dumps(f'AWS service error: {e}')}
    except Exception as e:
        logger.error(f"Unexpected error processing file {key} from bucket {bucket}: {e}", exc_info=True) # 스택 트레이스 포함 로깅
        # 예기치 않은 오류 시 500 반환 또는 raise e로 Lambda 재시도 유도 가능
        return {'statusCode': 500, 'body': json.dumps(f'An unexpected error occurred: {e}')}
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
  layers = [
    aws_lambda_layer_version.opensearch_libs_layer.arn,
    aws_lambda_layer_version.geoip_mmdb_layer.arn
    ]
  tags = var.tags
}

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
