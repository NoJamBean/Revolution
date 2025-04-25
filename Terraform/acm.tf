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

# 1. Private CA 생성
resource "tls_private_key" "private" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "private" {
  private_key_pem = tls_private_key.private.private_key_pem

  subject {
    common_name  = "api.backend.internal"
    organization = "Totoro"
  }

  validity_period_hours = 720
  is_ca_certificate     = false

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "self_signed" {
  private_key       = tls_private_key.private.private_key_pem
  certificate_body  = tls_self_signed_cert.private.cert_pem
}