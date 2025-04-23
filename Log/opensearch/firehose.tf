# --- S3 버킷 및 관련 설정 (기존과 동일) ---
resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "firehose_bucket" {
  bucket = "rds-firehose-backup-${random_id.suffix.hex}"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "firehose_bucket_pab" {
  bucket = aws_s3_bucket.firehose_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "firehose_bucket_sse" {
  bucket = aws_s3_bucket.firehose_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# --- Lambda 함수 및 관련 리소스 생성 ---

# Lambda 실행을 위한 IAM 역할
resource "aws_iam_role" "lambda_exec_role" {
  name = "firehose-lambda-exec-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  tags = var.tags
}

# Lambda 실행 역할에 필요한 기본 정책 연결 (CloudWatch Logs 쓰기 등)
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda 함수 코드를 포함하는 임시 zip 파일 생성 (인라인 방식)
data "archive_file" "lambda_s3_rds_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_s3_rds.zip" # 임시 zip 파일 경로

  # source 블록을 사용하여 코드 내용을 직접 정의
  source {
    # Lambda 핸들러에서 사용할 파일 이름 (예: index.py)
    filename = "index.py"
    # 실제 Python 코드 내용
    content = <<-EOF
import base64
import json
import re
import datetime

def lambda_handler(event, context):
    output_records = []

    for record in event['records']:
        try:
            payload_decoded = base64.b64decode(record['data']).decode('utf-8')

            # 매우 기본적인 파싱 예시 (실제 로그 형식에 맞게 정교화 필요)
            parsed_data = {
                'original_log': payload_decoded,
                '@timestamp': datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%S.%fZ'),
                'message': payload_decoded
            }

            # 간단한 정규식으로 타임스탬프와 메시지 분리 시도 (예시)
            match_z = re.match(r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z)\s+(\d+)\s+(.*)', payload_decoded)
            match_nodate = re.match(r'(\d{6}\s+\d{2}:\d{2}:\d{2})\s+(\d+)\s+(Query|Connect|Quit|Init DB)\s+(.*)', payload_decoded, re.IGNORECASE)

            if match_z:
                parsed_data['@timestamp'] = match_z.group(1)
                parsed_data['thread_id'] = match_z.group(2)
                parsed_data['message'] = match_z.group(3).strip()
            elif match_nodate:
                try:
                    log_time_str = match_nodate.group(1)
                    current_year = datetime.datetime.utcnow().year
                    log_dt = datetime.datetime.strptime(f"{current_year}{log_time_str}", "%Y%y%m%d %H:%M:%S")
                    parsed_data['@timestamp'] = log_dt.strftime('%Y-%m-%dT%H:%M:%S.%fZ')
                except ValueError:
                    pass # 파싱 실패 시 기본 타임스탬프 유지
                parsed_data['thread_id'] = match_nodate.group(2)
                parsed_data['log_type'] = match_nodate.group(3).strip()
                parsed_data['message'] = match_nodate.group(4).strip()

            output_record = {
                'recordId': record['recordId'],
                'result': 'Ok',
                'data': base64.b64encode(json.dumps(parsed_data).encode('utf-8')).decode('utf-8')
            }
            output_records.append(output_record)

        except Exception as e:
            print(f"Error processing record {record.get('recordId', 'N/A')}: {e}")
            output_record = {
                'recordId': record.get('recordId', 'N/A'),
                'result': 'ProcessingFailed',
                'data': record['data'] # 원본 데이터 반환
            }
            output_records.append(output_record)

    print(f"Processed {len(output_records)} records.")
    return {'records': output_records}
EOF
  }
}

# Lambda 함수 리소스 정의
resource "aws_lambda_function" "firehose_transformer" {
  filename         = data.archive_file.lambda_s3_rds_zip.output_path
  function_name    = "firehose-log-transformer-${random_id.suffix.hex}"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda_s3_rds_zip.output_base64sha256
  tags             = var.tags
  depends_on       = [aws_iam_role_policy_attachment.lambda_policy_attach]
}

# --- Firehose 역할 및 정책 (Lambda 호출 권한 추가) ---
resource "aws_iam_role" "firehose_role" {
  name = "firehose-opensearch-role-${random_id.suffix.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "firehose.amazonaws.com" } }]
  })
  tags = var.tags
}

resource "aws_iam_policy" "firehose_policy" {
  name        = "firehose-opensearch-policy-${random_id.suffix.hex}"
  description = "Policy for Firehose to write to OpenSearch, S3, and invoke Lambda"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["es:ESHttpPost", "es:ESHttpPut", "es:ESHttpGet", "es:DescribeDomain", "es:DescribeDomains", "es:DescribeDomainConfig"],
        Resource = [aws_opensearch_domain.log_domain.arn, "${aws_opensearch_domain.log_domain.arn}/*"]
      },
      {
        Effect = "Allow",
        Action = ["s3:AbortMultipartUpload", "s3:GetBucketLocation", "s3:GetObject", "s3:ListBucket", "s3:ListBucketMultipartUploads", "s3:PutObject"],
        Resource = [aws_s3_bucket.firehose_bucket.arn, "${aws_s3_bucket.firehose_bucket.arn}/*"]
      },
      {
        Effect   = "Allow",
        Action   = ["lambda:InvokeFunction", "lambda:GetFunctionConfiguration"],
        Resource = [aws_lambda_function.firehose_transformer.arn]
      },
      {
        Effect = "Allow",
        Action = ["logs:PutLogEvents"],
        Resource = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/kinesisfirehose/rds-general-logs-stream:log-stream:*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "firehose_attach" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_policy.arn
}

resource "aws_iam_role" "cw_logs_role" {
  name = "cw-logs-firehose-role-${random_id.suffix.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "logs.${data.aws_region.current.name}.amazonaws.com" } }]
  })
  tags = var.tags
}

resource "aws_iam_policy" "cw_logs_policy" {
  name        = "cw-logs-firehose-policy-${random_id.suffix.hex}"
  description = "Policy for CloudWatch Logs to put records into Firehose"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Effect = "Allow", Action = ["firehose:PutRecord", "firehose:PutRecordBatch"], Resource = aws_kinesis_firehose_delivery_stream.opensearch_stream.arn }]
  })
}

resource "aws_iam_role_policy_attachment" "cw_logs_attach" {
  role       = aws_iam_role.cw_logs_role.name
  policy_arn = aws_iam_policy.cw_logs_policy.arn
}

resource "aws_kinesis_firehose_delivery_stream" "opensearch_stream" {
  name        = "rds-general-logs-stream" 
  destination = "elasticsearch"

  elasticsearch_configuration {
    domain_arn            = aws_opensearch_domain.log_domain.arn
    role_arn              = aws_iam_role.firehose_role.arn
    index_name            = "rds-general-logs-stream"
    index_rotation_period = "OneDay"
    buffering_interval    = 300
    buffering_size        = 5
    retry_duration        = 300
    # S3 백업 설정은 이 블록 내 s3_backup_mode 로 처리
    s3_backup_mode        = "AllDocuments"
    s3_configuration {
      bucket_arn = aws_s3_bucket.firehose_bucket.arn
      role_arn = aws_iam_role.firehose_role.arn
    }
    processing_configuration {
      enabled = true # Lambda 변환 활성화
      processors {
        type = "Lambda"
        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = aws_lambda_function.firehose_transformer.arn # 생성된 Lambda ARN
        }
      }
    }
  }
  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.firehose_attach,
    aws_s3_bucket.firehose_bucket,
    aws_lambda_function.firehose_transformer
  ]
}

resource "aws_cloudwatch_log_subscription_filter" "rds_log_subscription" {
  name            = "${replace(var.source_log_group_name, "/", "-")}-to-rds-general-logs-stream"
  log_group_name  = var.source_log_group_name 
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.opensearch_stream.arn
  role_arn        = aws_iam_role.cw_logs_role.arn

  depends_on = [
    aws_iam_role_policy_attachment.cw_logs_attach,
    aws_kinesis_firehose_delivery_stream.opensearch_stream
  ]
}
