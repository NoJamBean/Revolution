# terraform.tfvars 파일 예시 (실제 값으로 채우세요)

aws_region = "ap-northeast-2"

opensearch_domain_name = "integration-log-timangs" # 원하는 도메인 이름

# 프로덕션 환경에 맞는 인스턴스 유형 및 개수 설정
# opensearch_instance_type = "m6g.large.search"
# opensearch_instance_count = 3

# 전역적으로 고유한 S3 버킷 이름 설정
cloudtrail_s3_bucket_name = "opensearch-timangs"

# OpenSearch 마스터 사용자 비밀번호 (실제 비밀번호로 변경)
# 보안을 위해 환경 변수나 다른 비밀 관리 도구 사용을 강력히 권장합니다.
opensearch_master_user_password = "0l03lV$3@l2krl"

tags = {
  Project     = "LogIntegration"
  Environment = "Development" # "Production" 또는 "Staging", "Development" 등
  Owner       = "kyu"
}
