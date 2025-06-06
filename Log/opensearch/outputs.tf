# --- 출력 ---
output "opensearch_domain_endpoint" {
  description = "OpenSearch 도메인 엔드포인트 URL"
  value       = aws_opensearch_domain.log_domain.endpoint
}

output "opensearch_domain_arn" {
  description = "OpenSearch 도메인 ARN"
  value       = aws_opensearch_domain.log_domain.arn
}

output "opensearch_kibana_endpoint" {
  description = "OpenSearch Dashboards (Kibana) 엔드포인트 URL"
  # Kibana 엔드포인트는 기본 엔드포인트 뒤에 '_dashboards/'가 붙습니다.
  # 고급 보안 옵션 활성화 시 접근하려면 마스터 사용자 인증 정보가 필요합니다.
  value = "${aws_opensearch_domain.log_domain.endpoint}/_dashboards/"
}

output "cloudtrail_s3_bucket_name" {
  description = "CloudTrail 로그가 저장되는 S3 버킷 이름"
  value       = aws_s3_bucket.cloudtrail_bucket.id
}

output "cloudtrail_name" {
  description = "생성된 CloudTrail 추적 이름"
  value       = aws_cloudtrail.main_trail.name
}

output "lambda_iam_role_arn" {
  description = "The ARN of the Lambda function's execution role."
  value = aws_iam_role.lambda_s3_opensearch_role.arn
}

#------------여기부터 RDS Metric을 위한 Output----------
output "firehose_iam_role_arn" {
  description = "The ARN of the Firehose delivery stream's execution role."
  value = aws_iam_role.firehose_role.arn
}

output "s3_rds_metrics_bucket_name" {
  value = aws_s3_bucket.rds_metrics_bucket.bucket
}

output "firehose_stream_arn" {
  value = aws_kinesis_firehose_delivery_stream.rds_metrics_stream.arn
}

output "metric_stream_arn" {
  value = aws_cloudwatch_metric_stream.rds_stream.arn
}