#Cognito
resource "aws_cognito_user_pool" "user_pool" {
  # depends_on = [ data.aws_route53_record.ses_verification_record]
  name = "bet-user-pool"

  auto_verified_attributes = ["email"]
  alias_attributes = ["email"]

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT" # AWS에서 자동 전송 처리
  }

  dynamic "schema" {
    for_each = [
      { name = "email", attribute_data_type = "String", required = true, mutable = true, developer_only_attribute = false },
      # { name = "nickname", attribute_data_type = "String", required = false, mutable = true, developer_only_attribute = false }
    ]
    content {
      name                     = schema.value.name
      attribute_data_type      = schema.value.attribute_data_type
      required                 = schema.value.required
      mutable                  = schema.value.mutable
      developer_only_attribute = schema.value.developer_only_attribute
    }
  }

  password_policy {
    minimum_length    = 6              # 최소 길이
    require_uppercase = false           # 대문자 포함
    require_lowercase = false           # 소문자 포함
    require_numbers   = false           # 숫자 포함
    require_symbols   = false           # 특수문자 포함
  }
}



resource "aws_cognito_user_pool_client" "app_client" {
  name         = "bet-app-client"
  user_pool_id = aws_cognito_user_pool.user_pool.id

  generate_secret                      = false
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  callback_urls                        = ["http://localhost/callback"] #프런트앱서버 주소 오토스케일링 그룹을 쓴다면 ALB주소

  # 토큰 유효 기간 설정
  access_token_validity = 10 # Access token validity in seconds (1 hour)
  id_token_validity     = 10 # ID token validity in seconds (1 hour)

  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

