resource "aws_iam_role" "firehose_role" {
  name = "${var.firehose_stream_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}

variable "firehose_stream_name" {
  description = "Kinesis Data Firehose 전송 스트림의 이름"
  type        = string
  default     = "rdsosmetrics-to-opensearch"
}

resource "aws_iam_policy" "firehose_policy" {
  name        = "${var.firehose_stream_name}-policy"
  description = "Policy for Kinesis Firehose to access S3, OpenSearch, and Lambda"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # S3 백업 버킷 쓰기 권한
      {
        Effect = "Allow",
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ],
        Resource = [
          "${aws_s3_bucket.firehose_backup.arn}",
          "${aws_s3_bucket.firehose_backup.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "es:ESHttpPost",
          "es:ESHttpPut",
          "es:DescribeDomain",
          "es:DescribeDomains",
          "es:DescribeDomainConfig" # 도메인 설정 확인 추가
        ],
        Resource = [
          "${aws_opensearch_domain.log_domain.arn}",
          "${aws_opensearch_domain.log_domain.arn}/*"
        ]
      },
      # 데이터 변환 Lambda 함수 호출 권한
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction",
          "lambda:GetFunctionConfiguration"
        ],
        Resource = "${aws_lambda_function.transform_lambda.arn}"
      },
      # CloudWatch Logs 로깅 권한 (Firehose 자체 로그)
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/kinesisfirehose/${var.firehose_stream_name}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "firehose_attach" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_policy.arn
}

# 2. Lambda 실행 역할 (데이터 변환용)
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.lambda_metric}-exec-role"

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
}

# Lambda 기본 실행 정책 연결 (CloudWatch Logs 쓰기 등)
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 3. CloudWatch Logs 구독 필터용 역할 (CloudWatch Logs -> Firehose 권한)
resource "aws_iam_role" "cw_to_firehose_role" {
  name = "CWLtoKinesisFirehoseRole-${var.firehose_stream_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "logs.${var.aws_region}.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
      
    ]
  })
}

# CloudWatch Logs 구독 필터용 역할 정책
resource "aws_iam_policy" "cw_to_firehose_policy" {
  name = "CWLtoKinesisFirehosePolicy-${var.firehose_stream_name}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
            "firehose:PutRecordBatch",
            "firehose:PutRecord"
            ]
        Resource = aws_kinesis_firehose_delivery_stream.opensearch_stream.arn
      },
      {
        Effect   = "Allow",
        Action   = "iam:PassRole", # Firehose 서비스에 역할 전달 권한
        Resource = aws_iam_role.firehose_role.arn # Firehose 실행 역할 ARN
      }
    ]
  })
}

# CloudWatch Logs 구독 필터 역할에 정책 연결
resource "aws_iam_role_policy_attachment" "cw_to_firehose_attach" {
  role       = aws_iam_role.cw_to_firehose_role.name
  policy_arn = aws_iam_policy.cw_to_firehose_policy.arn
}
