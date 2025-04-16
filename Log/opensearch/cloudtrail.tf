# --- CloudTrail 설정 ---

# 1. CloudTrail 로그 저장을 위한 S3 버킷 생성
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = var.cloudtrail_s3_bucket_name

  # 버킷 정책은 아래에서 별도로 정의
  # force_destroy = true # 테스트 환경에서는 버킷 삭제를 위해 true 설정 가능. 프로덕션에서는 주의!

  tags = var.tags
}

# S3 버킷 정책 (CloudTrail이 로그를 쓸 수 있도록 허용)
resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  policy = data.aws_iam_policy_document.cloudtrail_s3_policy.json
}

# CloudTrail S3 접근 정책 문서
data "aws_iam_policy_document" "cloudtrail_s3_policy" {
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
    resources = ["${aws_s3_bucket.cloudtrail_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"] # 계정 ID별 경로 지정
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
  include_global_service_events = true # 모든 리전의 글로벌 서비스 이벤트 포함 여부
  is_multi_region_trail         = true # 모든 리전에 적용
  enable_logging                = true

  # CloudWatch Logs 연동은 주석 처리 (필요 시 iam.tf 등에서 역할 생성 후 활성화)
  # cloud_watch_logs_group_arn = aws_cloudwatch_log_group.cloudtrail_log_group.arn
  # cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_cloudwatch_role.arn

  tags = var.tags
}

# --- 로그 전송 설정 (추가 구현 필요) ---
# 이 부분은 여전히 Lambda 함수, 로그 에이전트 설정 등 추가 Terraform 코드가 필요합니다.
# 예를 들어, Lambda 함수를 위한 'lambda.tf', 관련 IAM 역할을 위한 'iam.tf' 파일을 생성할 수 있습니다.
