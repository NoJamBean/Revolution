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

provider "aws" {
  alias  = "virginia"
  region = "us-east-1" # CloudFront는 반드시 us-east-1 인증서 필요
}

resource "aws_acm_certificate" "cloudfront_cert" {
  provider          = aws.virginia
  domain_name       = "1bean.shop"
  validation_method = "DNS"

  subject_alternative_names = [
    "www.1bean.shop"
  ]

  tags = {
    Name = "cloudfront-cert"
  }
}

resource "aws_acm_certificate_validation" "cloudfront_cert" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.cloudfront_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cloudfront_cert_validation : record.fqdn]
}