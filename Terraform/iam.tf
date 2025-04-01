# 1. IAM 역할 생성
resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2_s3_fullaccess_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# 2. S3 Full Access 정책 생성
resource "aws_iam_policy" "s3_full_access_policy" {
  name        = "S3FullAccessPolicy"
  description = "Allows full access to all S3 buckets and objects"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:ListAllMyBuckets"
        ]
        Resource = [
          "arn:aws:s3:::*/*",    # 모든 S3 객체에 대한 접근
          "arn:aws:s3:::*"       # 모든 S3 버킷에 대한 접근
        ]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "s3_full_access" {
  name       = "s3-full-access-attachment"
  roles      = [aws_iam_role.ec2_s3_role.name]
  policy_arn = aws_iam_policy.s3_full_access_policy.arn
}

# 3. IAM 인스턴스 프로파일 생성 (EC2에 연결하기 위함)
resource "aws_iam_instance_profile" "ec2_s3_profile" {
  name = "ec2_s3_profile"
  role = aws_iam_role.ec2_s3_role.name
}