#Cognito
resource "aws_cognito_user_pool" "user_pool" {
  name = "my-user-pool"

  auto_verified_attributes = ["email"]

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    required                 = true
    developer_only_attribute = false
  }
}

resource "aws_cognito_user_pool_client" "app_client" {
  name         = "my-app-client"
  user_pool_id = aws_cognito_user_pool.user_pool.id

  generate_secret = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = ["code", "implicit"]
  allowed_oauth_scopes = ["email", "openid", "profile"]
  callback_urls = ["http://localhost:5000/callback"] #프런트앱서버 주소 오토스케일링 그룹을 쓴다면 ALB주소
}