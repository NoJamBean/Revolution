# lambda_s3_rds_metrics.tf

# --- Lambda 함수 정의 ---
data "archive_file" "lambda_s3_rds_metrics_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_s3_rds_metrics.zip" # 임시 zip 파일 경로

  # source 블록을 사용하여 인라인 코드 제공
  source {
    filename = "index.py"
    content = <<-EOF
import json
import boto3
import os
import requests
from aws_requests_auth.aws_auth import AWSRequestsAuth
from datetime import datetime, timezone
import logging
import gzip # Firehose가 Gzip 압축 시 필요
from io import BytesIO, TextIOWrapper # Gzip 스트리밍 처리를 위해

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client('s3')

# --- 환경 변수에서 설정값 가져오기 ---
# 필수: OpenSearch 도메인 엔드포인트 (예: search-mydomain-xxxx.ap-northeast-2.es.amazonaws.com)
opensearch_endpoint = os.environ.get('OPENSEARCH_ENDPOINT')
# 선택: AWS 리전 (기본값: ap-northeast-2)
aws_region = os.environ.get('AWS_REGION', 'ap-northeast-2')
# 선택: OpenSearch 인덱스 접두사 (기본값: rds-metrics)
index_prefix = os.environ.get('INDEX_PREFIX', 'rds-metrics')

# --- 필수 환경 변수 검증 ---
if not opensearch_endpoint:
    # Lambda 실행 환경에서는 로깅 후 함수가 종료되도록 예외 발생시키는 것이 좋음
    logger.error("CRITICAL: OPENSEARCH_ENDPOINT environment variable not set.")
    raise ValueError("OPENSEARCH_ENDPOINT environment variable is required.")

# --- OpenSearch 인증 설정 ---
# aws_requests_auth는 호스트명만 필요로 하므로 'https://' 제거
opensearch_host = opensearch_endpoint.replace('https://', '')
aws_auth = None
try:
    # Lambda 실행 역할의 자격 증명을 사용
    credentials = boto3.Session().get_credentials()
    aws_auth = AWSRequestsAuth(aws_access_key=credentials.access_key,
                               aws_secret_access_key=credentials.secret_key,
                               aws_token=credentials.token,
                               aws_host=opensearch_host,
                               aws_region=aws_region,
                               aws_service='es') # OpenSearch Service의 서비스 이름은 'es'
    logger.info(f"AWS authentication configured for OpenSearch host: {opensearch_host}")
except Exception as e:
    logger.error(f"Error configuring AWS authentication: {e}", exc_info=True)
    # 인증 설정 실패 시, 함수 실행 중단
    raise RuntimeError(f"Failed to configure AWS authentication: {e}")

def lambda_handler(event, context):
    """
    S3 이벤트 트리거를 받아 Metric Stream 데이터를 OpenSearch로 전송하는 메인 핸들러 함수.
    """
    logger.info("Received event: " + json.dumps(event, indent=2))

    processed_records_count = 0
    failed_records_count = 0
    total_os_errors = 0

    # --- 이벤트 레코드 처리 루프 ---
    for record in event.get('Records', []):
        s3_bucket = None
        s3_key = None
        try:
            # S3 이벤트 정보 추출
            s3_info = record.get('s3', {})
            s3_bucket = s3_info.get('bucket', {}).get('name')
            # URL 인코딩된 '+' 문자를 공백으로 변환
            s3_key = s3_info.get('object', {}).get('key', '').replace('+', ' ')

            if not s3_bucket or not s3_key:
                logger.warning(f"Missing bucket name or object key in S3 record: {record}")
                failed_records_count += 1
                continue # 다음 레코드로 이동

            logger.info(f"Processing object s3://{s3_bucket}/{s3_key}")

            # --- S3 객체 읽기 ---
            response = s3.get_object(Bucket=s3_bucket, Key=s3_key)
            body = response['Body']

            # --- 파일 내용 처리 (Gzip 압축 고려) ---
            # Firehose에서 Gzip 압축 설정을 했다면 압축 해제 필요
            # 파일 확장자나 ContentEncoding 헤더로 압축 여부 판단 가능 (여기서는 키 이름으로 간단히 확인)
            lines = []
            if s3_key.endswith('.gz'):
                logger.info("Detected .gz extension, attempting Gzip decompression.")
                try:
                    with gzip.GzipFile(fileobj=body) as gzipfile:
                        # GzipFile 객체를 텍스트로 읽기 위해 TextIOWrapper 사용
                        with TextIOWrapper(gzipfile, encoding='utf-8') as decoder:
                            lines = decoder.read().strip().split('\n')
                except gzip.BadGzipFile:
                    logger.error(f"Failed to decompress Gzip file: {s3_key}. It might not be a valid Gzip file.")
                    # 압축 해제 실패 시, 일반 텍스트로 다시 시도 (선택적)
                    body.seek(0) # 스트림 포인터 초기화
                    lines = body.read().decode('utf-8').strip().split('\n')
                except Exception as gz_e:
                    logger.error(f"Error during Gzip decompression for {s3_key}: {gz_e}", exc_info=True)
                    failed_records_count += 1 # 파일 처리 실패로 간주
                    continue # 다음 레코드로 이동
            else:
                # 압축되지 않은 경우
                lines = body.read().decode('utf-8').strip().split('\n')

            logger.info(f"Read {len(lines)} lines from the file.")

            # --- OpenSearch 벌크 요청 데이터 생성 ---
            bulk_payload_lines = []
            current_file_processed = 0
            current_file_failed = 0

            for line in lines:
                line = line.strip()
                if not line: # 빈 줄 건너뛰기
                    continue
                try:
                    # 각 줄을 JSON으로 파싱
                    metric_data = json.loads(line)

                    # --- 데이터 변환 및 @timestamp 추가 ---
                    timestamp_ms = metric_data.get('timestamp')
                    timestamp_iso = None
                    # 기본 인덱스 날짜는 UTC 기준 현재 날짜
                    index_date_str = datetime.now(timezone.utc).strftime('%Y-%m-%d')

                    if isinstance(timestamp_ms, (int, float)):
                        try:
                            # 밀리초 타임스탬프를 UTC datetime 객체로 변환
                            dt_obj = datetime.fromtimestamp(timestamp_ms / 1000, tz=timezone.utc)
                            # ISO 8601 형식 (밀리초 포함)으로 변환
                            timestamp_iso = dt_obj.isoformat(timespec='milliseconds').replace('+00:00', 'Z') # 'Z'로 표시
                            # 메트릭 타임스탬프 기준으로 인덱스 날짜 결정
                            index_date_str = dt_obj.strftime('%Y-%m-%d')
                        except (ValueError, TypeError) as ts_e:
                             logger.warning(f"Could not parse timestamp '{timestamp_ms}': {ts_e}. Using current time.")
                             timestamp_iso = datetime.now(timezone.utc).isoformat(timespec='milliseconds').replace('+00:00', 'Z')
                    else:
                        logger.warning(f"Timestamp '{timestamp_ms}' is not a number. Using current time.")
                        timestamp_iso = datetime.now(timezone.utc).isoformat(timespec='milliseconds').replace('+00:00', 'Z')

                    # OpenSearch에서 사용할 타임스탬프 필드 추가
                    metric_data['@timestamp'] = timestamp_iso

                    # --- 벌크 API 라인 생성 ---
                    # 인덱스 이름 생성 (예: rds-metrics-2025-04-28)
                    index_name = f"{index_prefix}-{index_date_str}"
                    # 액션 메타데이터 라인 (인덱스 작업 지정)
                    action_line = json.dumps({"index": {"_index": index_name}})
                    # 문서 데이터 라인
                    document_line = json.dumps(metric_data)

                    bulk_payload_lines.append(action_line)
                    bulk_payload_lines.append(document_line)
                    current_file_processed += 1

                except json.JSONDecodeError as json_e:
                    logger.error(f"Failed to decode JSON line: {json_e}. Line (partial): '{line[:200]}...'")
                    current_file_failed += 1
                except Exception as proc_e:
                    logger.error(f"Error processing metric line: {proc_e}. Line (partial): '{line[:200]}...'")
                    current_file_failed += 1

            # --- 현재 파일에서 처리된 데이터가 있으면 OpenSearch로 전송 ---
            if bulk_payload_lines:
                final_bulk_data = '\n'.join(bulk_payload_lines) + '\n'
                # OpenSearch _bulk API 엔드포인트 URL
                url = f"https://{opensearch_host}/_bulk"
                headers = {"Content-Type": "application/x-ndjson"}

                num_actions = len(bulk_payload_lines) // 2
                logger.info(f"Sending {num_actions} metric records from s3://{s3_bucket}/{s3_key} to OpenSearch index pattern '{index_prefix}-*'...")

                try:
                    # OpenSearch로 POST 요청 전송
                    r = requests.post(url, auth=aws_auth, data=final_bulk_data.encode('utf-8'), headers=headers, timeout=60) # 타임아웃 증가 고려
                    logger.info(f"OpenSearch response status: {r.status_code}")

                    # --- OpenSearch 응답 처리 ---
                    os_batch_errors = 0
                    if r.status_code >= 300:
                        logger.error(f"OpenSearch bulk request failed. Status: {r.status_code}, Response (partial): {r.text[:1000]}")
                        # 전체 배치 실패로 간주, 개별 레코드 수만큼 실패 카운트 증가
                        os_batch_errors = num_actions
                    else:
                        # 응답 본문 파싱 시도
                        response_json = None
                        try:
                            response_json = r.json()
                        except json.JSONDecodeError:
                            logger.error(f"Could not decode JSON response from OpenSearch. Status: {r.status_code}, Response text (partial): {r.text[:500]}")
                            # 응답 파싱 실패 시, 전체 배치 실패로 간주할 수 있음
                            os_batch_errors = num_actions

                        # 응답 본문이 있고, 에러가 포함된 경우 개별 에러 확인
                        if response_json and response_json.get('errors'):
                            error_count = 0
                            items_with_errors = []
                            for item in response_json.get('items', []):
                                # 'index', 'create', 'update', 'delete' 등 다양한 액션 키 확인
                                action_type = list(item.keys())[0]
                                action_result = item.get(action_type, {})
                                # 상태 코드가 300 이상이거나 error 객체가 있으면 에러로 간주
                                if action_result.get('status', 0) >= 300 or action_result.get('error'):
                                    error_count += 1
                                    if error_count <= 10: # 로깅할 에러 수 제한
                                        items_with_errors.append(action_result)
                            if error_count > 0:
                               logger.warning(f"OpenSearch reported {error_count} errors out of {num_actions} items in the bulk response for file {s3_key}. First {len(items_with_errors)} errors: {json.dumps(items_with_errors)}")
                               os_batch_errors = error_count # 개별 에러 수 기록

                    # 배치 내 OpenSearch 에러 수 누적
                    total_os_errors += os_batch_errors
                    failed_records_count += os_batch_errors # 전체 실패 카운트에도 반영

                    if os_batch_errors == 0:
                         logger.info(f"Successfully sent {num_actions} records from s3://{s3_bucket}/{s3_key} to OpenSearch.")

                except requests.exceptions.RequestException as req_e:
                    logger.error(f"Network error sending data to OpenSearch for file {s3_key}: {req_e}", exc_info=True)
                    failed_records_count += num_actions # 네트워크 오류 시 해당 배치의 모든 레코드 실패 처리
                except Exception as os_e:
                    logger.error(f"Unexpected error during OpenSearch request for file {s3_key}: {os_e}", exc_info=True)
                    failed_records_count += num_actions # 기타 OpenSearch 오류 시 해당 배치의 모든 레코드 실패 처리
            else:
                logger.info(f"No valid metric lines found or processed in s3://{s3_bucket}/{s3_key}.")

            # 현재 파일 처리 결과 집계
            processed_records_count += current_file_processed
            # 파싱 실패 카운트도 누적 (이미 위에서 current_file_failed로 누적함)
            failed_records_count += current_file_failed


        # --- S3 접근 또는 파일 처리 중 발생한 예외 처리 ---
        except s3.exceptions.NoSuchKey:
             logger.error(f"S3 object s3://{s3_bucket}/{s3_key} not found. It might have been deleted.")
             failed_records_count += 1 # 파일 접근 실패
        except s3.exceptions.ClientError as s3_e:
            logger.error(f"Boto3 client error accessing s3://{s3_bucket}/{s3_key}: {s3_e}", exc_info=True)
            failed_records_count += 1 # 파일 접근 실패
        except Exception as e:
            # 어떤 파일 처리 중 에러가 났는지 명시
            key_info = s3_key if s3_key else "N/A"
            logger.error(f"Unexpected error processing S3 record for key {key_info}: {e}", exc_info=True)
            failed_records_count += 1 # 예상치 못한 오류

    # --- 최종 실행 결과 로깅 및 반환 ---
    logger.info(f"Lambda execution finished. Total records processed and attempted send: {processed_records_count}, Total failures (parsing/sending): {failed_records_count}")

    # 최종 상태 코드 결정
    if failed_records_count > 0 and processed_records_count > 0:
        status_code = 207 # 부분 성공
        body = f'Processed {processed_records_count} records with {failed_records_count} failures.'
    elif failed_records_count > 0 and processed_records_count == 0:
        status_code = 500 # 완전 실패 또는 처리할 레코드 없음
        body = f'Failed to process records. Failures: {failed_records_count}.'
    elif failed_records_count == 0 and processed_records_count > 0:
        status_code = 200 # 성공
        body = f'Successfully processed {processed_records_count} records.'
    else: # 처리한 레코드도, 실패도 없음 (예: 빈 이벤트, 빈 파일)
        status_code = 200
        body = 'No records processed.'

    return {
        'statusCode': status_code,
        'body': json.dumps(body)
    }
EOF
  }
}

# 5. Lambda 함수 리소스 정의 (Layer 적용)
resource "aws_lambda_function" "s3_to_rds_metrics_lambda" {
  filename         = data.archive_file.lambda_s3_rds_metrics_zip.output_path
  source_code_hash = data.archive_file.lambda_s3_rds_metrics_zip.output_base64sha256
  function_name = "s3-to-opensearch-rds_metrics"
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
    aws_lambda_layer_version.opensearch_libs_layer.arn
    ]
  tags = var.tags
}

# --- Lambda 함수 호출 권한 및 S3 이벤트 트리거 설정 ---
resource "aws_lambda_permission" "allow_s3_invocation_rds_metrics" {
  statement_id  = "AllowS3InvokeFunction"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_to_rds_metrics_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.rds_metrics_bucket.arn
  source_account = data.aws_caller_identity.current.account_id
}
resource "aws_s3_bucket_notification" "rds_metrics_bucket_notification" {
  bucket = aws_s3_bucket.rds_metrics_bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_to_rds_metrics_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "rds-metrics/"
  }
  depends_on = [aws_lambda_permission.allow_s3_invocation_rds_metrics]
}
