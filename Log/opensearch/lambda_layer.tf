# lambda_layer.tf

# Dockerfile 등으로 생성된 lambda_layer.zip 파일이
# 현재 Terraform 실행 디렉토리(${path.module})에 있다고 가정합니다.

# Lambda Layer Version 리소스 생성
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
