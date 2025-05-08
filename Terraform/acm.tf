resource "aws_acm_certificate" "alb_cert" {
  domain_name       = "1bean.shop"
  validation_method = "DNS"

  subject_alternative_names = [
    "www.1bean.shop"
  ]

  tags = {
    Name = "alb-cert"
  }
}

resource "aws_acm_certificate_validation" "alb_cert" {
  certificate_arn         = aws_acm_certificate.alb_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.alb_cert_validation : record.fqdn]
}


# resource "aws_acm_certificate" "sin_alb_cert" {
#   provider = aws.singapore
#   domain_name       = "1bean.shop"
#   validation_method = "DNS"

#   subject_alternative_names = [
#     "www.1bean.shop"
#   ]

#   tags = {
#     Name = "alb-cert"
#   }
# }

# resource "aws_acm_certificate_validation" "sin_alb_cert" {
#   provider = aws.singapore
#   certificate_arn         = aws_acm_certificate.sin_alb_cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.alb_cert_validation : record.fqdn]
# }