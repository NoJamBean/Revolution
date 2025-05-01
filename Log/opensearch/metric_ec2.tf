resource "aws_s3_bucket" "ec2_metrics_bucket" {
  bucket = "ec2-metrics-bucket-${random_id.bucket_suffix.hex}" # 고유한 버킷 이름으로 변경하세요.

  tags = {
    Name = "ec2 Metrics Destination Bucket"
  }
  force_destroy = true
}

resource "aws_s3_bucket_lifecycle_configuration" "ec2_metrics_bucket_lifecycle" {
  bucket = aws_s3_bucket.ec2_metrics_bucket.id
  rule {
    id     = "ec2-metrics-bucket-rule"
    status = "Enabled"
    filter {
      prefix = "*"
    }
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    expiration {
      days = 180
    }
  }
}

# resource "aws_iam_role" "firehose_role" {
#   name = "firehose-s3-delivery-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "firehose.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "firehose_s3_policy" {
#   name        = "firehose-s3-delivery-policy"
#   description = "Policy for Firehose to deliver data to S3"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "s3:AbortMultipartUpload",
#           "s3:GetBucketLocation",
#           "s3:GetObject",
#           "s3:ListBucket",
#           "s3:ListBucketMultipartUploads",
#           "s3:PutObject"
#         ],
#         Resource = [
#           "${aws_s3_bucket.ec2_metrics_bucket.arn}",
#           "${aws_s3_bucket.ec2_metrics_bucket.arn}/*"
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "firehose_s3_attach" {
#   role       = aws_iam_role.firehose_role.name
#   policy_arn = aws_iam_policy.firehose_s3_policy.arn
# }

resource "aws_kinesis_firehose_delivery_stream" "ec2_metrics_stream" {
  name        = "ec2-metrics-firehose-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.ec2_metrics_bucket.arn
    prefix     = "ec2-metrics/"
    error_output_prefix = "ec2-metrics-errors/"
    # 버퍼링 설정 (필요에 따라 조절)
    # buffering_interval = 60
    # buffering_size = 1
  }
  tags = {
    Name = "ec2 Metrics Firehose Stream"
  }
}

# resource "aws_iam_role" "metric_stream_role" {
#   name = "metric-stream-to-firehose-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "streams.metrics.cloudwatch.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "metric_stream_firehose_policy" {
#   name        = "metric-stream-firehose-policy"
#   description = "Policy for Metric Stream to put recoec2 into Firehose"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "firehose:PutRecord",
#           "firehose:PutRecordBatch"
#         ],
#         Resource = "${aws_kinesis_firehose_delivery_stream.ec2_metrics_stream.arn}"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "metric_stream_firehose_attach" {
#   role       = aws_iam_role.metric_stream_role.name
#   policy_arn = aws_iam_policy.metric_stream_firehose_policy.arn
# }

resource "aws_cloudwatch_metric_stream" "ec2_stream" {
  name_prefix  = "ec2-metrics-"
  role_arn     = aws_iam_role.metric_stream_role.arn
  firehose_arn = aws_kinesis_firehose_delivery_stream.ec2_metrics_stream.arn
  output_format = "json"
  include_filter {
    namespace = "AWS/EC2"
  }
  tags = {
    Name = "ec2 Metrics Stream"
  }
  depends_on = [
    aws_kinesis_firehose_delivery_stream.ec2_metrics_stream,
    aws_iam_role_policy_attachment.metric_stream_firehose_attach,
  ]
}
