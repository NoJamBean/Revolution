# opensearch.tf

# --- OpenSearch 도메인 생성 ---
resource "aws_opensearch_domain" "log_domain" {
  domain_name    = var.opensearch_domain_name # 변수 사용 (variables.tf 정의)
  engine_version = "OpenSearch_2.17"       # 필요에 따라 버전 조정

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
  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "${aws_iam_role.lambda_s3_opensearch_role.arn}"
        }
        Action = "es:*"
        Resource = "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.opensearch_domain_name}/*"
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = "es:*"
        Resource = "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/${var.opensearch_domain_name}/*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" = ["121.160.41.207/32","58.120.222.122/32","59.9.132.74/32","118.37.11.111/32","211.104.182.166/32"]
          }
        }
      }
    ]
  })
  # data.aws_caller_identity.current 는 providers.tf 등에 정의 필요
  # aws_iam_role.lambda_s3_opensearch_role 는 lambda_s3_opensearch.tf 에 정의 필요

  # 고급 보안 옵션 (Fine-Grained Access Control) - 반드시 활성화 상태 유지
  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
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
