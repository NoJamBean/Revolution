resource "aws_s3_bucket" "firehose_backup" {
  bucket = "${var.firehose_s3_backup_bucket_name}-${random_id.bucket_suffix.hex}"
  # 버킷 정책, 버전 관리 등 필요에 따라 추가 설정 가능 
}

data "archive_file" "lambda_rds_metric_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_rds_metric.zip"
  source {
    filename = "index.py"
    content = <<-EOF
import json
import base64
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):

    output_records = []

    for record in event['records']:
        try:
            # 1. 레코드 데이터 디코딩 (Base64)
            payload_compressed = base64.b64decode(record['data'])
            try:
                payload_uncompressed = gzip.decompress(payload_compressed).decode('utf-8')
                # logger.debug(f"Decompressed payload: {payload_uncompressed}") # 디버깅 시 유용
            except gzip.BadGzipFile:
                logger.warning(f"Record {record_id} data is not gzip compressed? Trying direct decode.")
                # 혹시 압축되지 않은 데이터가 올 경우 대비 (일반적이지 않음)
                payload_uncompressed = payload_compressed.decode('utf-8')
            except Exception as decomp_err:
                 logger.error(f"Failed to decompress/decode data for record {record_id}: {decomp_err}")
                 output_records.append({
                    'recordId': record_id,
                    'result': 'ProcessingFailed',
                    'data': record['data']
                 })
                 continue

            # 2. CloudWatch Logs 이벤트 형식 파싱
            cw_log_data = json.loads(payload_decoded)
            # logger.debug(f"CloudWatch Log Data: {cw_log_data}")

            # 3. 실제 RDSOSMetrics 데이터 추출 (message 필드)
            message_str = cw_log_data.get('message')
            if not message_str:
                logger.warning(f"Record {record['recordId']} has empty message, dropping.")
                output_records.append({
                    'recordId': record['recordId'],
                    'result': 'Dropped',
                    'data': record['data'] # 원본 데이터 반환 (선택 사항)
                })
                continue

            # 4. RDSOSMetrics JSON 파싱
            try:
                rds_metric_data = json.loads(message_str)
                # logger.debug(f"Parsed RDS Metric Data: {rds_metric_data}")
            except json.JSONDecodeError as json_err:
                 logger.error(f"Failed to parse JSON message in record {record['recordId']}: {json_err}. Message: {message_str[:500]}...")
                 output_records.append({
                    'recordId': record['recordId'],
                    'result': 'ProcessingFailed',
                    'data': record['data']
                 })
                 continue

            # 5. (선택 사항) 데이터 가공/정제
            # 예: 타임스탬프 형식 변경, 필드 이름 변경, 불필요 필드 제거 등
            # rds_metric_data['@timestamp'] = rds_metric_data.pop('timestamp') # 예시: 필드 이름 변경

            # 6. 변환된 데이터를 Base64로 다시 인코딩
            output_payload = json.dumps(rds_metric_data)
            output_data_encoded = base64.b64encode(output_payload.encode('utf-8')).decode('utf-8')

            output_records.append({
                'recordId': record['recordId'],
                'result': 'Ok',
                'data': output_data_encoded
            })

        except Exception as e:
            logger.error(f"Error processing record {record.get('recordId', 'UNKNOWN')}: {e}", exc_info=True)
            # 처리 실패 시 'ProcessingFailed'로 표시하여 Firehose가 S3에 백업하도록 함
            output_records.append({
                'recordId': record['recordId'],
                'result': 'ProcessingFailed',
                'data': record['data'] # 원본 데이터 반환
            })

    logger.info(f"Successfully processed {len(event['records'])} records. Outputting {len(output_records)} records.")

    return {'records': output_records}
EOF
  }
}

resource "aws_lambda_function" "transform_lambda" {
  filename         = data.archive_file.lambda_rds_metric_zip.output_path
  source_code_hash = data.archive_file.lambda_rds_metric_zip.output_base64sha256
  function_name    = var.lambda_metric
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler" 
  runtime          = "python3.9"
  timeout = 60 
  memory_size = 128 
}

resource "aws_kinesis_firehose_delivery_stream" "opensearch_stream" {
  name        = var.firehose_stream_name
  destination = "opensearch"

  opensearch_configuration {
    domain_arn = aws_opensearch_domain.log_domain.arn
    role_arn   = aws_iam_role.firehose_role.arn
    index_name = "rds"

    s3_configuration {
      role_arn           = aws_iam_role.firehose_role.arn
      bucket_arn         = aws_s3_bucket.firehose_backup.arn
      buffering_size     = 10
      buffering_interval = 400
      compression_format = "GZIP"
    }

    processing_configuration {
      enabled = "true"
      processors {
        type = "Lambda"
        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.transform_lambda.arn}:$LATEST"
        }
      }
    }
  }
}

resource "aws_cloudwatch_log_subscription_filter" "rds_to_firehose" {
  name            = "rds-to-${var.firehose_stream_name}"
  log_group_name  = "RDSOSMetrics"
  filter_pattern  = "" 
  destination_arn = aws_kinesis_firehose_delivery_stream.opensearch_stream.arn
  role_arn        = aws_iam_role.cw_to_firehose_role.arn
  depends_on = [
    aws_kinesis_firehose_delivery_stream.opensearch_stream,
    aws_iam_role_policy_attachment.cw_to_firehose_attach
  ]
}
