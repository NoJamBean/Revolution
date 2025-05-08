# resource "aws_route53_zone" "public" {
#   # count = length(data.aws_route53_zone.public_zone.id) > 0 ? 0 : 1

#   name = var.public_domain_name

#   lifecycle {
#     prevent_destroy = true # terraform destroy 시 삭제되지 않도록 보호
#     ignore_changes = [ vpc ]
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

# #싱가포르 연결
# resource "aws_route53_zone_association" "sin_private_zone_association" {
#   provider = aws.singapore
#   zone_id = data.aws_route53_zone.private.id
#   vpc_id  = aws_vpc.sin_vpc.id
# }


#Public Record
# resource "aws_route53_record" "web_alb_a_record" {
#   count   = 2
#   zone_id = data.aws_route53_zone.public.zone_id
#   name    = "www.${var.public_domain_name}"
#   type    = "A"

#   set_identifier = ["korea", "singapore"][count.index]

#   geolocation_routing_policy {
#     country = ["KR", "SG"][count.index]
#   }

#   failover_routing_policy {
#     type = "PRIMARY"  # 첫 번째 리전이 primary
#   }

#   alias {
#     name                   = [aws_lb.alb.dns_name, aws_lb.sin_alb.dns_name][count.index]
#     zone_id                = [aws_lb.alb.zone_id, aws_lb.sin_alb.zone_id][count.index]
#     evaluate_target_health = true
#   }

#   health_check_id = [aws_route53_health_check.korea_health_check.id, aws_route53_health_check.singapore_health_check.id][count.index]

#   depends_on = [aws_lb.alb, aws_lb.sin_alb]
# }

# resource "aws_route53_record" "web_alb_a_record" {
#   zone_id = data.aws_route53_zone.public.zone_id
#   name    = "www.${var.public_domain_name}"
#   type    = "A"

#   set_identifier = "korea"  # 'korea'만 남김

#   geolocation_routing_policy {
#     country = "KR"  # 'KR'만 남김
#   }

#   failover_routing_policy {
#     type = "PRIMARY"  # 첫 번째 리전이 primary
#   }

#   alias {
#     name                   = aws_lb.alb.dns_name
#     zone_id                = aws_lb.alb.zone_id
#     evaluate_target_health = true
#   }

#   health_check_id = aws_route53_health_check.korea_health_check.id

#   depends_on = [aws_lb.alb]
# }

# resource "aws_route53_health_check" "korea_health_check" {
#   fqdn = "www.${var.public_domain_name}" # 트래픽을 확인할 DNS 이름
#   type = "HTTP"
#   resource_path = "/" # 건강 상태를 확인할 경로

#   failure_threshold = 3
#   request_interval  = 30
# }

# resource "aws_route53_health_check" "singapore_health_check" {
#   fqdn = "www.${var.public_domain_name}"
#   type = "HTTP"
#   resource_path = "/"

#   failure_threshold = 3
#   request_interval  = 30
# }

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "www.1bean.shop"
  type    = "CNAME"
  ttl     = 60

  records = [
    kubernetes_ingress_v1.nextjs.status[0].load_balancer[0].ingress[0].hostname
  ]
  depends_on = [ kubernetes_ingress_v1.nextjs ]
}

# resource "aws_route53_record" "web_app_service_cname_record" {
#   zone_id = data.aws_route53_zone.public.zone_id
#   name    = "www.${var.public_domain_name}"  # 기존 도메인 이름
#   type    = "CNAME"
  
#   ttl     = 60  # TTL 설정
#   records = ["app-service-webapp.azurewebsites.net"]  # Azure App Service의 DNS 이름 (기본 DNS 이름)

#   # depends_on = [aws_route53_zone]
# }

# resource "aws_route53_record" "nat" {
#   zone_id = data.aws_route53_zone.public.zone_id
#   name    = "nat"
#   type    = "A"
#   ttl     = "300"
#   records = [aws_instance.nat_instance1.public_ip]
#   set_identifier = "default"
#   geolocation_routing_policy {
#     # default로 지정
#     country = "KR"
#   }
# }

#Private Records
resource "aws_route53_record" "alb" {
  zone_id = data.aws_route53_zone.private.id
  name    = "alb.backend.internal"
  type    = "A"

  alias {
    name                   = aws_lb.private_alb.dns_name
    zone_id                = aws_lb.private_alb.zone_id
    evaluate_target_health = true
  }
  set_identifier = "default"
  geolocation_routing_policy {
    # default로 지정
    country = "KR"
  }
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.private.id
  name    = "api"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.api_server_1.private_ip]
  set_identifier = "default"
  geolocation_routing_policy {
    # default로 지정
    country = "KR"
  }
}

resource "aws_route53_record" "db" {
  zone_id = data.aws_route53_zone.private.id
  name    = "db"
  type    = "CNAME"
  ttl     = "300"
  records = [split(":", aws_db_instance.mysql_multi_az.endpoint)[0]]
  set_identifier = "default"
  geolocation_routing_policy {
    # default로 지정
    country = "KR"
  }
}

#cert_validation
resource "aws_route53_record" "alb_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.alb_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  zone_id = data.aws_route53_zone.public.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}


#싱가포르 도메인
# resource "aws_route53_record" "sin_web_alb_a_record" {
#   provider = aws.singapore
#   zone_id = data.aws_route53_zone.public.zone_id
#   name    = "www.${var.public_domain_name}"
#   type    = "A"
  
#   set_identifier = "singapore"
#   geolocation_routing_policy {
#     country = "SG"
#   }
#   alias {
#     name                   = aws_lb.sin_alb.dns_name
#     zone_id                = aws_lb.sin_alb.zone_id
#     evaluate_target_health = true
#   }
#   depends_on = [ aws_lb.sin_alb ]
# }

# resource "aws_route53_record" "alb_sin" {
#   provider = aws.singapore
#   zone_id = data.aws_route53_zone.private.id
#   name    = "alb.backend.internal"
#   type    = "A"

#   set_identifier = "singapore"
#   geolocation_routing_policy {
#     country = "SG"  # 싱가포르에 대한 설정
#   }
#   alias {
#     name                   = aws_lb.sin_private_alb.dns_name
#     zone_id                = aws_lb.sin_private_alb.zone_id
#     evaluate_target_health = true
#   }
# }

# resource "aws_route53_record" "api_sin" {
#   provider = aws.singapore
#   zone_id = data.aws_route53_zone.private.id
#   name    = "api"
#   type    = "A"
#   ttl     = "300"
#   records = [aws_instance.sin_api_server_1.private_ip]
#   set_identifier = "singapore"
#   geolocation_routing_policy {
#     country = "SG"  # 싱가포르에 대한 설정
#   }
# }

# resource "aws_route53_record" "db_sin" {
#   provider = aws.singapore
#   zone_id = data.aws_route53_zone.private.id
#   name    = "db"
#   type    = "CNAME"
#   ttl     = "300"
#   records = [split(":", aws_db_instance.sin_mysql_read_replica.endpoint)[0]]
#   set_identifier = "singapore"
#   geolocation_routing_policy {
#     country = "SG"  # 싱가포르에 대한 설정
#   }
# }



# resource "aws_route53_resolver_endpoint" "inbound" {
#   name       = "r53-inbound"
#   direction  = "INBOUND"
#   security_group_ids = [aws_security_group.default_sg.id]
#   # vpc_id     = aws_vpc.vpc.id

#   ip_address {
#     subnet_id = aws_subnet.subnet["api1"].id
#     ip        = "10.0.100.10"
#   }
#   ip_address {
#     subnet_id = aws_subnet.subnet["ws1"].id
#     ip        = "10.0.15.10"
#   }
# }