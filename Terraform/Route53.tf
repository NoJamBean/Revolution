# resource "aws_route53_zone" "public" {
#   count = length(data.aws_route53_zone.public_zone.id) > 0 ? 0 : 1

#   name = var.public_domain_name

#   lifecycle {
#     prevent_destroy = true # terraform destroy 시 삭제되지 않도록 보호
#   }
# }


#존은 생성되어있으면 주석처리하고 data쪽을 주석처리 풀어야함
# resource "aws_route53_zone" "private" {
#   # count = length(data.aws_route53_zone.private.id) > 0 ? 0 : 1
#   name         = var.private_domain_name
#   vpc {
#     vpc_id = aws_vpc.vpc.id
#   }

#   lifecycle {
#     prevent_destroy = true # terraform destroy 시 삭제되지 않도록 보호
#     ignore_changes = [vpc] 
#   }
# }

resource "aws_route53_zone_association" "private_zone_association" {
  zone_id = data.aws_route53_zone.private.id
  vpc_id  = aws_vpc.vpc.id
}

#Private Records
resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.private.id
  name    = "api"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.api_server_1.private_ip] # API 서버의 프라이빗 IP 주소 입력
}

resource "aws_route53_record" "db" {
  zone_id = data.aws_route53_zone.private.id
  name    = "db"
  type    = "CNAME"
  ttl     = "300"
  records = [split(":", aws_db_instance.mysql_multi_az.endpoint)[0]]
}