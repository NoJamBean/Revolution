resource "aws_cloudfront_distribution" "frontend" {
  enabled         = true
  is_ipv6_enabled = true

  origin {
    domain_name = aws_lb.alb.dns_name
    origin_id   = "alb-web-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "alb-web-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "POST", "OPTIONS"]
    cached_methods         = ["GET", "OPTIONS"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    min_ttl     = 3600    # 1시간 캐시 (자주 안 바뀌면 더 올려도 됨)
    default_ttl = 86400   # 1일
    max_ttl     = 31536000 # 1년
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn = var.cloudfront_acm_cert_arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "frontend-cf"
  }
}
