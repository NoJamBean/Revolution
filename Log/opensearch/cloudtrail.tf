resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "cloudtrail_bucket" {
  # 이전과 동일 ...
  # 버킷 이름 변수 값이 'opensearch-timangs-log' 로 설정되어 있다고 가정합니다.
  bucket = "${var.cloudtrail_s3_bucket_name}-${random_id.bucket_suffix.hex}"
  force_destroy = true
  tags   = var.tags
}

# S3 버킷 정책 (CloudTrail이 로그를 쓸 수 있도록 허용)
resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  policy = data.aws_iam_policy_document.cloudtrail_s3_policy.json
}

# CloudTrail S3 접근 정책 문서
data "aws_iam_policy_document" "cloudtrail_s3_policy" {
  # 이전과 동일 ...
  statement {
    sid       = "AWSCloudTrailAclCheck"
    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail_bucket.arn]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
    sid       = "AWSCloudTrailWrite"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
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

# 2. CloudTrail 추적 생성
resource "aws_cloudtrail" "main_trail" {
  name                          = "main-log-integration-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  # CloudWatch Logs 연동 주석 처리됨 ...

  tags = var.tags

  # S3 버킷 정책이 먼저 적용되도록 명시적 의존성 추가
  depends_on = [
    aws_s3_bucket_policy.cloudtrail_bucket_policy
  ]
}
