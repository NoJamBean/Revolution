resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "${var.cloudtrail_s3_bucket_name}-${random_id.bucket_suffix.hex}"
  force_destroy = true
  tags   = var.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_bucket_lifecycle" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  # Lifecycle 규칙 정의
  rule {
    id     = "${var.cloudtrail_s3_bucket_name}-rule"
    status = "Enabled"
    filter {
      prefix = "AWSLogs/"
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

resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  policy = data.aws_iam_policy_document.cloudtrail_s3_policy.json
}

data "aws_iam_policy_document" "cloudtrail_s3_policy" {
  statement {
    sid       = "AWSCloudTrailAclCheck"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [
      aws_s3_bucket.cloudtrail_bucket.arn, 
      ]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
    sid       = "AWSCloudTrailWrite"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.cloudtrail_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      ]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_iam_role_policy" "lambda_s3_getobject_policy" {
  role = "lambda-s3-opensearch-role"
  name = "S3GetObjectWebAppLogsPolicy" 
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "${data.aws_s3_bucket.web_bucket.arn}",
          "${data.aws_s3_bucket.web_bucket.arn}/*",
          "${data.aws_s3_bucket.tfstate_bucket.arn}",
          "${data.aws_s3_bucket.tfstate_bucket.arn}/*",
        ]
      },
    ]
  })
  depends_on = [ aws_iam_role.lambda_s3_opensearch_role ]
}

resource "aws_cloudtrail" "main_trail" {
  name                          = "main-log-integration-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  tags = var.tags

  depends_on = [
    aws_s3_bucket_policy.cloudtrail_bucket_policy
  ]
}
