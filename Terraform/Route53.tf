# 기존 퍼블릭 호스팅 영역이 있으면 사용, 없으면 생성
# data "aws_route53_zone" "public_zone" {
#   name         = var.public_domain_name
#   private_zone = false
# }

# resource "aws_route53_zone" "public_zone" {
#   count = length(data.aws_route53_zone.public_zone.id) > 0 ? 0 : 1

#   name = var.public_domain_name

#   lifecycle {
#     prevent_destroy = true # terraform destroy 시 삭제되지 않도록 보호
#   }
# }

# 기존 프라이빗 호스팅 영역이 있으면 사용, 없으면 생성
data "aws_route53_zone" "private_zone" {
  name         = var.private_domain_name
  # private_zone = true
}

resource "aws_route53_zone" "primary" {
  count = length(data.aws_route53_zone.private_zone.id) > 0 ? 0 : 1
  name         = var.private_domain_name
  # private_zone = true
  vpc {
    vpc_id = aws_vpc.vpc.id
  }

  lifecycle {
    prevent_destroy = true # terraform destroy 시 삭제되지 않도록 보호
  }
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.private_zone.id
  name    = "api"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.dotnet_api_server.private_ip] # API 서버의 프라이빗 IP 주소 입력
}

resource "aws_route53_record" "db" {
  zone_id = data.aws_route53_zone.private_zone.id
  name    = "db"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.rds_access_instance.private_ip] # DB 서버의 프라이빗 IP 주소 입력
}