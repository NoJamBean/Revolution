# --- OpenSearch 도메인 생성 ---
resource "aws_opensearch_domain" "log_domain" {
  domain_name    = var.opensearch_domain_name
  engine_version = "OpenSearch_2.11" # 필요에 따라 버전 조정

  cluster_config {
    instance_type           = var.opensearch_instance_type
    instance_count          = var.opensearch_instance_count
    dedicated_master_enabled = false # 작은 클러스터에서는 false. 큰 클러스터에서는 true 고려
    zone_awareness_enabled   = var.opensearch_instance_count > 1 # 여러 AZ에 분산 (고가용성)
    zone_awareness_config {
      availability_zone_count = var.opensearch_instance_count > 1 ? 2 : null # 2개 또는 3개의 AZ 사용
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp3" # gp3 권장
    volume_size = var.ebs_volume_size
  }

  # 중요: 접근 정책 설정
  # 이 정책은 매우 개방적입니다. 프로덕션 환경에서는 특정 IAM 역할/사용자, IP 주소, VPC 엔드포인트 등으로 접근을 제한해야 합니다.
  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          # 실제 환경에서는 data.aws_caller_identity.current.account_id 또는 특정 역할 ARN으로 제한
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "es:*" # 실제 환경에서는 필요한 최소한의 권한 (예: es:ESHttp*) 부여
        Resource = "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.opensearch_domain_name}/*"
      }
      # 필요에 따라 추가적인 접근 제어 정책 추가 (예: 특정 IP 대역 허용)
    ]
  })

  # 고급 보안 옵션 (Fine-Grained Access Control) 활성화 권장
  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true # 내부 사용자 데이터베이스 사용
    master_user_options {
      master_user_name     = "admin" # 내부 마스터 사용자 이름
      master_user_password = var.opensearch_master_user_password # variables.tf 에서 정의, 민감 정보
    }
  }

  # 노드 간 암호화 및 저장 데이터 암호화 활성화
  node_to_node_encryption {
    enabled = true
  }
  encrypt_at_rest {
    enabled = true
  }

  # 도메인 엔드포인트 옵션 (HTTPS 강제)
  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07" # 최신 보안 정책 사용 권장
  }

  tags = var.tags
}
