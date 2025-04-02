# API Gateway REST API 생성
resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "dotnet-api-gateway"
  description = "API Gateway for .NET Core API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API Gateway 리소스 생성 (EC2로 프록시)
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "{proxy+}"
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
resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.proxy.id  
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

# OPTIONS 메서드 추가
resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

#Intergration
# API Gateway 통합 설정 (EC2 프록시)
resource "aws_api_gateway_integration" "proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_method.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_instance.dotnet_api_server.public_ip}/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
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

# API Gateway 배포
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.proxy_integration, aws_api_gateway_method.proxy_method]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
}

# resource "aws_cloudwatch_log_subscription_filter" "filter_errors" {
#   name            = "apigateway-error-filter"
#   log_group_name  = "/aws/apigateway/welcome"
#   filter_pattern  = "{ $.status >= 400 }"  # 4xx, 5xx 에러만 로깅
#   destination_arn = "arn:aws:logs:ap-northeast-2:248189921892:log-group:/aws/apigateway/welcome" # 필터링된 로그를 저장할 Lambda 또는 다른 대상
#   role_arn = var.agwlog_role_arn
# }

# API Gateway Stage 설정
resource "aws_api_gateway_stage" "api_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id

  # # 실행 로그 설정
  # access_log_settings {
  #   destination_arn = "arn:aws:logs:ap-northeast-2:248189921892:log-group:/aws/apigateway/welcome"
  #   format = jsonencode({
  #     requestId       = "$context.requestId"
  #     extendedRequestId = "$context.extendedRequestId"
  #     ip              = "$context.identity.sourceIp"
  #     caller          = "$context.identity.caller"
  #     user            = "$context.identity.user"
  #     requestTime     = "$context.requestTime"
  #     httpMethod      = "$context.httpMethod"
  #     resourcePath    = "$context.resourcePath"
  #     status          = "$context.status"
  #     responseLatency = "$context.responseLatency"
  #   })
  # }
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
  }
}

# OPTIONS 응답 헤더 설정
resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST'"
    "method.response.header.Access-Control-Allow-Headers" = "'Origin, X-Requested-With, Content-Type, Accept, Authorization'"
  }
}