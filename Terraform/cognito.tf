#Cognito
resource "aws_cognito_user_pool" "user_pool" {
  name = "my-user-pool"

  auto_verified_attributes = ["email"]

  dynamic "schema" {
    for_each = [
      { name = "email", attribute_data_type = "String", required = true, mutable = true, developer_only_attribute = false },
      { name = "nickname", attribute_data_type = "String", required = false, mutable = true, developer_only_attribute = false }
    ]
    content {
      name                     = schema.value.name
      attribute_data_type      = schema.value.attribute_data_type
      required                 = schema.value.required
      mutable                  = schema.value.mutable
      developer_only_attribute = schema.value.developer_only_attribute
    }
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

  # 토큰 유효 기간 설정
  access_token_validity = 10  # Access token validity in seconds (1 hour)
  id_token_validity     = 10  # ID token validity in seconds (1 hour)

  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}