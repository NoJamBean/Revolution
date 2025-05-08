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

# output "aws_vpn_pip" {
#   value = aws_vpn_gateway.vpn_gateway.public_ip
# }
output "azure_vpn_pip" {
  value = azurerm_public_ip.vpn_gateway_pip.ip_address
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "kubeconfig" {
  value = <<EOT
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.main.endpoint}
    certificate-authority-data: ${aws_eks_cluster.main.certificate_authority[0].data}
  name: ${aws_eks_cluster.main.name}
contexts:
- context:
    cluster: ${aws_eks_cluster.main.name}
    user: aws
  name: ${aws_eks_cluster.main.name}
current-context: ${aws_eks_cluster.main.name}
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--region"
        - "ap-northeast-2"
        - "--cluster-name"
        - "${aws_eks_cluster.main.name}"
EOT
}