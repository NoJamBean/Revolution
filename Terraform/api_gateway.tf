locals {
  cors_origin      = "'http://localhost:3000'"
  cors_methods     = "'GET,POST'"
  cors_headers     = "'*'"
  cors_credentials = "'true'"
}

# API Gateway REST API 생성
resource "aws_api_gateway_method_settings" "agw" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = aws_api_gateway_stage.api_stage.stage_name
  method_path = "*/*"

  settings {
    caching_enabled = false
  }
}

resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "dotnet-api-gateway"
  description = "API Gateway for .NET Core API"

  endpoint_configuration {
    types = ["PRIVATE"]
  }
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "api"
}

# API Gateway 리소스 생성 (EC2로 프록시)
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "users"
}

# /api/register 리소스
resource "aws_api_gateway_resource" "register" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_resource.users.id
  path_part   = "register"
}

# Cognito Authorizer 설정
resource "aws_api_gateway_authorizer" "cognito_auth" {
  name            = "cognito-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.rest_api.id
  type            = "COGNITO_USER_POOLS"
  provider_arns   = [aws_cognito_user_pool.user_pool.arn]
  identity_source = "method.request.header.Authorization"

  # # Authorization Scopes 비활성화 (aud 검증 제거)
  # authorizer_result_ttl_in_seconds = 0
}

#Method
# API Gateway 메서드에 경로 파라미터 정의
resource "aws_api_gateway_method" "get_proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.proxy.id  
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id

  request_parameters = {
    "method.request.path.proxy" = true
    "method.request.header.Origin" = true
    "method.request.header.X-Requested-With" = true
    "method.request.header.Content-Type" = true
    "method.request.header.Accept" = true
    "method.request.header.Authorization" = true
  }
}

# OPTIONS 메서드 추가
resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "post_register_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.register.id
  http_method   = "POST"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.Origin"           = true
    "method.request.header.Content-Type"     = true
    "method.request.header.Accept"           = true
    "method.request.header.X-Requested-With" = true
  }
}

resource "aws_api_gateway_method" "post_proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id

  request_parameters = {
    "method.request.path.proxy" = true
    "method.request.header.Origin" = true
    "method.request.header.X-Requested-With" = true
    "method.request.header.Content-Type" = true
    "method.request.header.Accept" = true
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_method_response" "get_proxy_method_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.get_proxy_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
}

# OPTIONS 메서드 응답 정의
resource "aws_api_gateway_method_response" "options_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
}

resource "aws_api_gateway_method_response" "post_proxy_method_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.post_proxy_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Credentials" = true
  }
}

resource "aws_api_gateway_method_response" "post_register_method_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.register.id
  http_method = aws_api_gateway_method.post_register_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"      = true
    "method.response.header.Access-Control-Allow-Methods"     = true
    "method.response.header.Access-Control-Allow-Headers"     = true
    "method.response.header.Access-Control-Allow-Credentials" = true
  }

  response_models = {
    "application/json" = "Empty"
  }
}

#Intergration
# API Gateway 통합 설정 (EC2 프록시)
resource "aws_api_gateway_integration" "get_proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.get_proxy_method.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${chomp(aws_route53_record.api.fqdn)}"
  timeout_milliseconds = 29000
  

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
    # "integration.request.header.Origin" = "'https://${aws_api_gateway_rest_api.rest_api.id}.execute-api.ap-northeast-2.amazonaws.com'"
    "integration.request.header.Origin" = "method.request.header.Origin"
    "integration.request.header.X-Requested-With" = "method.request.header.X-Requested-With"
    "integration.request.header.Content-Type" = "method.request.header.Content-Type"
    "integration.request.header.Accept" = "method.request.header.Accept"
    "integration.request.header.Authorization" = "method.request.header.Authorization"
  }
}

# OPTIONS 요청을 처리하는 Mock Integration 추가
resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "post_proxy_integration" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.post_proxy_method.http_method

  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "http://${chomp(aws_route53_record.api.fqdn)}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
    "integration.request.header.Origin" = "method.request.header.Origin"
    "integration.request.header.X-Requested-With" = "method.request.header.X-Requested-With"
    "integration.request.header.Content-Type" = "method.request.header.Content-Type"
    "integration.request.header.Accept" = "method.request.header.Accept"
    "integration.request.header.Authorization" = "method.request.header.Authorization"
  }
}

resource "aws_api_gateway_integration" "post_register_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.register.id
  http_method             = aws_api_gateway_method.post_register_method.http_method
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "http://${chomp(aws_route53_record.api.fqdn)}"

  request_parameters = {
    "integration.request.header.Origin"           = "method.request.header.Origin"
    "integration.request.header.Content-Type"     = "method.request.header.Content-Type"
    "integration.request.header.Accept"           = "method.request.header.Accept"
    "integration.request.header.X-Requested-With" = "method.request.header.X-Requested-With"
  }
}

resource "aws_api_gateway_integration_response" "get_proxy_integration_response" {
  depends_on = [ aws_api_gateway_integration.get_proxy_integration ]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.get_proxy_method.http_method
  status_code = aws_api_gateway_method_response.get_proxy_method_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = local.cors_origin
    "method.response.header.Access-Control-Allow-Methods" = local.cors_methods
    "method.response.header.Access-Control-Allow-Headers" = local.cors_headers
    "method.response.header.Access-Control-Allow-Credentials" = local.cors_credentials
  }
}

# OPTIONS 응답 헤더 설정
resource "aws_api_gateway_integration_response" "options_integration_response" {
  depends_on = [ aws_api_gateway_method_response.options_response ]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = local.cors_origin
    "method.response.header.Access-Control-Allow-Methods" = local.cors_methods
    "method.response.header.Access-Control-Allow-Headers" = local.cors_headers
    "method.response.header.Access-Control-Allow-Credentials" = local.cors_credentials
  }
}

resource "aws_api_gateway_integration_response" "post_proxy_integration_response" {
  depends_on  = [aws_api_gateway_integration.post_proxy_integration]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.post_proxy_method.http_method
  status_code = aws_api_gateway_method_response.post_proxy_method_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = local.cors_origin
    "method.response.header.Access-Control-Allow-Methods" = local.cors_methods
    "method.response.header.Access-Control-Allow-Headers" = local.cors_headers
    "method.response.header.Access-Control-Allow-Credentials" = local.cors_credentials
  }
}

resource "aws_api_gateway_integration_response" "post_register_integration_response" {
  depends_on  = [aws_api_gateway_integration.post_register_integration]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.register.id
  http_method = aws_api_gateway_method.post_register_method.http_method
  status_code = aws_api_gateway_method_response.post_register_method_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"      = local.cors_origin
    "method.response.header.Access-Control-Allow-Methods"     = local.cors_methods
    "method.response.header.Access-Control-Allow-Headers"     = local.cors_headers
    "method.response.header.Access-Control-Allow-Credentials" = local.cors_credentials
  }
}

# API Gateway 배포
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.get_proxy_integration, aws_api_gateway_method.get_proxy_method]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
}


# API Gateway Stage 설정
resource "aws_api_gateway_stage" "api_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id

  cache_cluster_enabled = false # 캐시 비활성화
}