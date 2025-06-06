variable "aws_region" {
  description = "배포할 AWS 리전"
  type        = string
  default     = "ap-northeast-2" # 예: 서울 리전
}

variable "opensearch_domain_name" {
  description = "생성할 OpenSearch 도메인 이름"
  type        = string
  default     = "log-integration-domain"
}

variable "opensearch_instance_type" {
  description = "OpenSearch 도메인의 인스턴스 유형"
  type        = string
  default     = "m5.large.search" # 개발/테스트용. 프로덕션 환경에서는 더 큰 유형 고려
}

variable "opensearch_instance_count" {
  description = "OpenSearch 도메인의 데이터 노드 수"
  type        = number
  default     = 3 # 개발/테스트용. 프로덕션 환경에서는 3 이상 권장 (고가용성)
}

variable "ebs_volume_size" {
  description = "OpenSearch 데이터 노드당 EBS 볼륨 크기 (GB)"
  type        = number
  default     = 10
}

variable "cloudtrail_s3_bucket_name" {
  description = "CloudTrail 로그를 저장할 S3 버킷 이름 (전역적으로 고유해야 함)"
  type        = string
}

variable "opensearch_master_user_password" {
  description = "OpenSearch 고급 보안 마스터 사용자 비밀번호"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "리소스에 적용할 공통 태그"
  type        = map(string)
  default = {
    Project     = "LogIntegration"
    Environment = "Development"
  }
}

data "aws_s3_bucket" "web_bucket" {
  bucket =  "bet-application-total-logs"

}

variable "source_log_group_name" {
  description = "로그 데이터를 가져올 CloudWatch Logs 그룹 이름"
  type        = string
  default     = "/aws/rds/instance/mysql-multi-az-rds-instance/general"
}

data "aws_s3_bucket" "tfstate_bucket" {
  bucket = "tfstate-bucket-revolution112233"
}

variable "firehose_s3_backup_bucket_name" {
  default = "firehose-backup"
  type = string
}

variable "lambda_metric" {
  default = "firehose-metric"
  type = string
}