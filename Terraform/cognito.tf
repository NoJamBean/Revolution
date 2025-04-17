#Cognito
resource "aws_cognito_user_pool" "user_pool" {
  name = "my-user-pool"

  # auto_verified_attributes = ["email"]
  alias_attributes = ["email"]

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = false
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }


  // 필수 입력값 (Cognito 자체 생성 필드)
  schema {
    name                     = "nickname"
    attribute_data_type      = "String"
    required                 = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 3
      max_length = 20
    }
  }

  // 커스텀 생성 필드
  schema {
    name                     = "balance"
    attribute_data_type      = "Number"
    required                 = false
    developer_only_attribute = false
  }
}



resource "aws_cognito_user_pool_client" "app_client" {
  name         = "my-app-client"
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
    # "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

#더미데이터
resource "aws_cognito_user" "dummy_user" {
  username     = "dummyuser"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  attributes = {
    email    = "dummyuser@example.com"
    nickname = "wha"
  }

  temporary_password = "TemporaryPassword123!"

  message_action = "SUPPRESS" # 인증 메일 발송을 방지

  force_alias_creation = false
}
