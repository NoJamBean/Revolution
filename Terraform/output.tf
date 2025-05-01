output "cognito_user_pool_arn" {
  value = aws_cognito_user_pool.user_pool.arn
}

# 로그 저장용 s3 버킷이름 출력
output "s3_bucket_name" {
  value = aws_s3_bucket.log_bucket.bucket
}


# azuer vpn public IP
output "azure_vpn_public_ip" {
  value = azurerm_public_ip.vpn_gateway_pip.ip_address
}
