output "db_endpoint" {
  value = split(":", aws_db_instance.mysql_multi_az.endpoint)[0]
  sensitive = true
}

output "api_address" {
  description = "API SERVER의 공인 IP 주소"
  value       = "http://${aws_instance.dotnet_api_server.public_ip}:5000/api/users/test"
}

# API Gateway의 URL 출력
output "api_gateway_url" {
  description = "API Gateway 엔드포인트"
  value       = "${aws_api_gateway_deployment.api_deployment.invoke_url}/{proxy}"
}

# EC2의 퍼블릭 IP 출력
output "ec2_public_ip" {
  description = "EC2의 퍼블릭 IP"
  value       = aws_instance.dotnet_api_server.public_ip
}