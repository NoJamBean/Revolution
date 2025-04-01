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
  name          = "cognito-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.user_pool.arn]
  identity_source = "method.request.header.Authorization"
}

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

# API Gateway 통합 설정 (EC2 프록시)
resource "aws_api_gateway_integration" "proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_method.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${aws_instance.dotnet_api_server.private_ip}:80/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

# API Gateway 배포
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on  = [aws_api_gateway_integration.proxy_integration, aws_api_gateway_method.proxy_method]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
}

# API Gateway Stage 설정
resource "aws_api_gateway_stage" "api_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
}

