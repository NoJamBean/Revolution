# lambda_layer.tf

# --- Lambda 함수 실행을 위한 IAM 역할 및 정책 ---
# (IAM 역할, 정책, 정책 연결 부분은 이전과 동일)
resource "aws_iam_role" "lambda_s3_opensearch_role" {
  name = "lambda-s3-opensearch-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [ { Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } } ]
  })
  tags = var.tags
}
resource "aws_iam_policy" "lambda_s3_opensearch_policy" {
  name        = "lambda-s3-opensearch-policy"
  description = "Policy for Lambda to read CloudTrail logs from S3 and write to OpenSearch"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Effect = "Allow", Resource = "arn:aws:logs:*:*:*" },
      { Action = ["s3:GetObject", "s3:ListBucket"], Effect = "Allow", Resource = [ "${aws_s3_bucket.cloudtrail_bucket.arn}", "${aws_s3_bucket.cloudtrail_bucket.arn}/*" ] },
      { Action = ["es:ESHttpPost", "es:ESHttpPut", "es:ESHttpGet"], Effect = "Allow", Resource = "${aws_opensearch_domain.log_domain.arn}/*" }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_s3_opensearch_attach" {
  role       = aws_iam_role.lambda_s3_opensearch_role.name
  policy_arn = aws_iam_policy.lambda_s3_opensearch_policy.arn
}


resource "aws_lambda_layer_version" "opensearch_libs_layer" {
  layer_name = "opensearch-python-libs" # Lambda Layer 이름

  # --- 수정된 부분: S3 참조 대신 로컬 파일 직접 참조 ---
  # 로컬 zip 파일 경로 지정 (${path.module}은 현재 디렉토리를 의미)
  filename   = "${path.module}/lambda_layer.zip"

  # 파일 내용이 변경될 때 Layer 버전이 업데이트되도록 파일 해시 참조
  source_code_hash = filebase64sha256("${path.module}/lambda_layer.zip")

  # 이 Layer와 호환되는 Lambda 런타임 지정
  compatible_runtimes = ["python3.9"] # Lambda 함수 런타임과 일치

  description = "Layer containing requests and aws-requests-auth libraries for OpenSearch Lambda (From local zip)"

  # 라이선스 정보 (선택 사항)
  # license_info = "MIT"
}
