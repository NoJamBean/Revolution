# lambda_s3_cloudtrail.tf

# --- Lambda 함수 정의 ---
data "archive_file" "lambda_s3_cloudtrail_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_s3_cloudtrail.zip" # 임시 zip 파일 경로

  # source 블록을 사용하여 인라인 코드 제공
  source {
    filename = "index.py"
    content = <<-EOF
import json
import boto3
import gzip
import os
import requests
from aws_requests_auth.aws_auth import AWSRequestsAuth
from datetime import datetime
import logging
import ipaddress # <--- ipaddress 모듈 추가
import geoip2.database

logger = logging.getLogger()
logger.setLevel(logging.INFO)
s3 = boto3.client('s3')
opensearch_endpoint = os.environ['OPENSEARCH_ENDPOINT']
aws_region = os.environ.get('AWS_REGION', 'ap-northeast-2')
db_path = os.environ.get('GEOIP_DB_PATH', '/opt/GeoLite2-City.mmdb')
reader = None # 초기화

try:
    logger.info(f"Attempting to load GeoIP database from: {db_path}")
    reader = geoip2.database.Reader(db_path)
    logger.info("GeoIP database loaded successfully.")
except FileNotFoundError:
    logger.error(f"CRITICAL: GeoIP Database not found at {db_path}. GeoIP enrichment will be disabled.")
    reader = None # 명시적으로 None 설정
except Exception as e:
    logger.error(f"CRITICAL: Failed to load GeoIP database from {db_path}: {e}. GeoIP enrichment will be disabled.")
    reader = None # 명시적으로 None 설정


# SigV4 인증 설정 (기존 코드 유지)
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
        # URL 인코딩된 '+' 문자를 공백으로 변환 후 다시 원복 (일반적으로 불필요하나 원본 로직 유지)
        key = event['Records'][0]['s3']['object']['key'].replace('+', ' ')
        # key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key']) # 더 표준적인 방법
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

        bulk_payload_lines = []
        for record in records:
            try:
                ip_address = record.get('sourceIPAddress')
                is_valid_ip = False # IP 유효성 플래그

                if ip_address:
                    try:
                        # --- IP 주소 형식 검증 ---
                        ipaddress.ip_address(ip_address)
                        is_valid_ip = True
                    except ValueError:
                        # --- 유효한 IP가 아닐 경우 처리 ---
                        logger.debug(f"'{ip_address}' is not a valid IP. Moving to sourceDomain.")
                        record['sourceDomain'] = ip_address # sourceDomain 필드에 값 저장
                        del record['sourceIPAddress']      # 기존 sourceIPAddress 필드 삭제
                        is_valid_ip = False
                    except Exception as ip_err:
                         # 예상치 못한 ipaddress 모듈 오류 처리
                         logger.error(f"Error validating IP {ip_address}: {ip_err}")
                         is_valid_ip = False # 안전하게 처리

                # --- GeoIP 처리 (유효한 IP일 때만 수행) ---
                if is_valid_ip and reader:
                    try:
                        geo_response = reader.city(ip_address)
                        geo_info = {}
                        # ... (기존 GeoIP 정보 추출 로직 유지) ...
                        if geo_response.country.iso_code: geo_info['country_iso_code'] = geo_response.country.iso_code
                        if geo_response.country.name: geo_info['country_name'] = geo_response.country.name
                        if geo_response.subdivisions.most_specific.name: geo_info['subdivision_name'] = geo_response.subdivisions.most_specific.name
                        if geo_response.city.name: geo_info['city_name'] = geo_response.city.name
                        if geo_response.postal.code: geo_info['postal_code'] = geo_response.postal.code
                        if geo_response.location.latitude and geo_response.location.longitude:
                            geo_info['location'] = {'lat': geo_response.location.latitude, 'lon': geo_response.location.longitude}

                        if geo_info:
                            record['geoip'] = geo_info

                    except geoip2.errors.AddressNotFoundError:
                        logger.debug(f"IP address not found in GeoIP database: {ip_address}")
                    # ValueError는 위에서 처리했으므로 여기서는 발생 가능성 낮음
                    except Exception as geo_e:
                        logger.error(f"Error during GeoIP lookup for {ip_address}: {geo_e}")
                elif not is_valid_ip and ip_address: # ip_address가 있었지만 유효하지 않은 경우
                     logger.debug(f"Skipping GeoIP lookup for non-IP source: {record.get('sourceDomain')}")
                elif not reader and is_valid_ip:
                     logger.warning(f"GeoIP reader not available, skipping enrichment for valid IP: {ip_address}")


                # --- 인덱스 이름 생성 (기존 로직 유지) ---
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

                # Bulk API 페이로드 생성
                bulk_payload_lines.append(json.dumps({"index": {"_index": index_name}}))
                bulk_payload_lines.append(json.dumps(record)) # 수정된 record 사용

            except Exception as e:
                logger.error(f"Error processing individual record: {e}. Record: {json.dumps(record)}")


        if not bulk_payload_lines:
             logger.info("No valid records processed to send.")
             return {'statusCode': 200, 'body': json.dumps('No records to send after processing.')}

        final_bulk_data = '\n'.join(bulk_payload_lines) + '\n'

        # --- OpenSearch로 데이터 전송 (기존 코드 유지) ---
        url = f"https://{opensearch_endpoint}/_bulk"
        headers = {"Content-Type": "application/x-ndjson"}

        r = requests.post(url, auth=aws_auth, data=final_bulk_data.encode('utf-8'), headers=headers)

        logger.info(f"OpenSearch response status: {r.status_code}")

        # --- 응답 처리 및 오류 로깅 (기존 코드 유지, 약간 개선) ---
        response_body = r.text # 오류 발생 시 원문 확인을 위해 미리 저장
        if r.status_code >= 300:
             logger.error(f"OpenSearch request failed with status {r.status_code}")
             logger.error(f"Failed response body: {response_body}") # 전체 응답 로깅

        try:
            response_json = r.json()
            if response_json.get('errors'):
                error_count = 0
                items_with_errors = [] # 오류 항목 샘플 저장
                logger.warning("Errors reported by OpenSearch Bulk API:")
                for item in response_json.get('items', []):
                    # index, create, update, delete 작업 모두 확인
                    op_type = item.get('index') or item.get('create') or item.get('update') or item.get('delete')
                    if op_type and 'error' in op_type:
                        error_count += 1
                        if error_count <= 10: # 처음 10개 오류만 상세 로깅
                            logger.warning(f"  Item Error: {op_type['error']}")
                            # 오류 발생한 원본 레코드 찾기 (근사치) - bulk_payload_lines 사용
                            # Bulk API 응답 순서와 요청 순서가 일치한다고 가정
                            try:
                                 # 응답 아이템 순서(0부터 시작) * 2 + 1 이 원본 데이터 라인 인덱스
                                 item_index = response_json['items'].index(item)
                                 failed_record_line_index = item_index * 2 + 1
                                 if failed_record_line_index < len(bulk_payload_lines):
                                     logger.warning(f"  Failed Record (approx): {bulk_payload_lines[failed_record_line_index][:500]}...") # 너무 길면 자르기
                                 else:
                                      logger.warning("  Could not retrieve corresponding failed record from payload.")
                            except Exception as lookup_err:
                                 logger.warning(f"  Could not lookup failed record: {lookup_err}")

                if error_count > 10:
                    logger.warning(f"  ... and {error_count - 10} more errors.")

        except json.JSONDecodeError:
             # 성공(2xx) 응답인데 JSON 파싱 실패하는 경우는 드물지만 로깅
             if r.status_code < 300 :
                  logger.error(f"Could not decode JSON from successful response. Response text: {response_body}")
             # 실패 응답(300 이상)의 경우 이미 위에서 response_body 로깅됨

        # 최종 처리 상태 로그
        logger.info(f"Successfully processed {key} and attempted to send {len(records)} records. Final status: {r.status_code}")

        if r.status_code < 300 and not (response_json and response_json.get('errors')):
             return {'statusCode': 200, 'body': json.dumps('Successfully processed logs.')}
        else:
             # 부분 성공/실패가 있을 수 있으므로, 최종 상태는 200 OK 반환하되 로그에 오류 기록
             # 또는 오류 발생 시 500 반환 원하면 아래 주석 해제
             # return {'statusCode': 500, 'body': json.dumps(f'Failed to send some logs to OpenSearch. Status: {r.status_code}')}
             logger.warning("Returning 200 OK despite some item errors reported by Bulk API.")
             return {'statusCode': 200, 'body': json.dumps('Processed logs with some item errors reported.')}


    except json.JSONDecodeError as e:
        logger.error(f"Error decoding JSON from file {key}: {e}")
        return {'statusCode': 400, 'body': json.dumps('Invalid JSON format in log file.')}
    except Exception as e:
        logger.error(f"Error processing file {key} from bucket {bucket}: {e}", exc_info=True)
        # 프로덕션에서는 에러 리턴 대신 DLQ 등으로 보내는 것을 고려
        raise e
EOF
  }
}

# 5. Lambda 함수 리소스 정의 (Layer 적용)
resource "aws_lambda_function" "s3_to_cloudtrail_lambda" {
  filename         = data.archive_file.lambda_s3_cloudtrail_zip.output_path
  source_code_hash = data.archive_file.lambda_s3_cloudtrail_zip.output_base64sha256
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
  layers = [
    aws_lambda_layer_version.opensearch_libs_layer.arn,
    aws_lambda_layer_version.geoip_mmdb_layer.arn
    ]
  tags = var.tags
}

# --- Lambda 함수 호출 권한 및 S3 이벤트 트리거 설정 ---
resource "aws_lambda_permission" "allow_s3_invocation_cloudtrail" {
  statement_id  = "AllowS3InvokeFunction"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_to_cloudtrail_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.cloudtrail_bucket.arn
  source_account = data.aws_caller_identity.current.account_id
}
resource "aws_s3_bucket_notification" "cloudtrail_bucket_notification" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_to_cloudtrail_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".gz"
  }
  depends_on = [aws_lambda_permission.allow_s3_invocation_cloudtrail]
}
