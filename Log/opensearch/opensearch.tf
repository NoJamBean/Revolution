# opensearch.tf

# --- OpenSearch 도메인 생성 ---
resource "aws_opensearch_domain" "log_domain" {
  domain_name    = var.opensearch_domain_name # 변수 사용 (variables.tf 정의)
  engine_version = "OpenSearch_2.11"       # 필요에 따라 버전 조정

  cluster_config {
    instance_type           = var.opensearch_instance_type    # 변수 사용
    instance_count          = var.opensearch_instance_count   # 변수 사용
    dedicated_master_enabled = false                         # 작은 클러스터용
    zone_awareness_enabled   = var.opensearch_instance_count > 1 # 고가용성 설정
    zone_awareness_config {
      availability_zone_count = var.opensearch_instance_count > 1 ? 2 : null
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp3"
    volume_size = var.ebs_volume_size # 변수 사용
  }

  # 중요: 접근 정책 설정
  # Lambda 역할 ARN이 포함된 접근 정책
  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            # 계정 루트 또는 Terraform 실행 주체 등 기존 접근 허용 Principal
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
            # CloudTrail 로그 수집 Lambda 함수의 실행 역할 ARN 추가
            "${aws_iam_role.lambda_s3_opensearch_role.arn}"
          ]
        }
        # 실제 운영 환경에서는 "es:ESHttpPost", "es:ESHttpPut" 등 최소 권한 부여 권장
        Action = "es:*"
        # 리소스 ARN 정확히 지정
        Resource = "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.opensearch_domain_name}/*"
      }
      # 필요시 IP 기반 제한 등 다른 정책 구문 추가 가능
    ]
  })
  # data.aws_caller_identity.current 는 providers.tf 등에 정의 필요
  # aws_iam_role.lambda_s3_opensearch_role 는 lambda_s3_opensearch.tf 에 정의 필요

  # 고급 보안 옵션 (Fine-Grained Access Control)
  advanced_security_options {
    enabled                        = false
    internal_user_database_enabled = false
    master_user_options {
      master_user_name     = "admin" # 마스터 사용자 이름
      master_user_password = var.opensearch_master_user_password # 변수 사용 (variables.tf 정의, sensitive = true)
    }
  }

  # 노드 간 암호화 및 저장 데이터 암호화
  node_to_node_encryption {
    enabled = true
  }
  encrypt_at_rest {
    enabled = true
  }

  # 도메인 엔드포인트 옵션 (HTTPS 강제)
  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  tags = var.tags # 공통 태그 적용 (variables.tf 정의)
}
