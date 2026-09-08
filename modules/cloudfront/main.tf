locals {
  webapp_root = trimsuffix(var.webapp_root_prefix, "/")
}

resource "aws_cloudfront_origin_access_control" "webapp" {
  name                              = "${var.name_prefix}-webapp"
  description                       = "Origin access control for ${var.app_name} webapp"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_cache_policy" "webapp_disabled" {
  name        = "${var.name_prefix}-webapp-disabled"
  comment     = "Disable cache for ${var.app_name} webapp"
  default_ttl = 0
  max_ttl     = 1
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = false
    enable_accept_encoding_gzip   = false

    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_cache_policy" "polly_api" {
  count = var.polly_proxy_enabled ? 1 : 0

  name        = "${var.name_prefix}-polly-api"
  comment     = "Polly proxy cache policy for ${var.app_name}"
  default_ttl = 0
  max_ttl     = 1
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "whitelist"

      headers {
        items = ["authorization", "content-type"]
      }
    }

    query_strings_config {
      query_string_behavior = "all"
    }
  }
}

resource "aws_cloudfront_cache_policy" "translate_api" {
  count = var.translate_proxy_enabled ? 1 : 0

  name        = "${var.name_prefix}-translate-api"
  comment     = "Translate proxy cache policy for ${var.app_name}"
  default_ttl = 0
  max_ttl     = 1
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "whitelist"

      headers {
        items = ["authorization", "content-type"]
      }
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "polly_api" {
  count = var.polly_proxy_enabled ? 1 : 0

  name    = "${var.name_prefix}-polly-api"
  comment = "Polly proxy origin request policy for ${var.app_name}"

  cookies_config {
    cookie_behavior = "none"
  }

  headers_config {
    header_behavior = "allExcept"

    headers {
      items = ["host"]
    }
  }

  query_strings_config {
    query_string_behavior = "all"
  }
}

resource "aws_cloudfront_origin_request_policy" "translate_api" {
  count = var.translate_proxy_enabled ? 1 : 0

  name    = "${var.name_prefix}-translate-api"
  comment = "Translate proxy origin request policy for ${var.app_name}"

  cookies_config {
    cookie_behavior = "none"
  }

  headers_config {
    header_behavior = "allExcept"

    headers {
      items = ["host"]
    }
  }

  query_strings_config {
    query_string_behavior = "none"
  }
}

resource "aws_cloudfront_function" "polly_url_rewrite" {
  count = var.polly_proxy_enabled ? 1 : 0

  name    = "${var.name_prefix}-polly-url-rewrite"
  runtime = "cloudfront-js-2.0"
  comment = "Remove the Polly proxy path prefix before forwarding to AWS."
  publish = true
  code    = file("${path.module}/functions/polly-url-rewrite.js")
}

resource "aws_cloudfront_function" "translate_url_rewrite" {
  count = var.translate_proxy_enabled ? 1 : 0

  name    = "${var.name_prefix}-translate-url-rewrite"
  runtime = "cloudfront-js-2.0"
  comment = "Remove the Translate proxy path prefix before forwarding to AWS."
  publish = true
  code    = file("${path.module}/functions/translate-url-rewrite.js")
}

resource "aws_cloudfront_distribution" "webapp" {
  comment         = "CloudFront for ${var.app_name}"
  enabled         = true
  is_ipv6_enabled = false
  price_class     = "PriceClass_All"

  default_root_object = "index.html"

  logging_config {
    bucket          = var.webapp_log_bucket_domain_name
    include_cookies = false
    prefix          = "cloudfront-logs/"
  }

  origin {
    domain_name              = var.webapp_bucket_regional_domain_name
    origin_id                = "webapp-s3"
    origin_access_control_id = aws_cloudfront_origin_access_control.webapp.id
    origin_path              = "/${local.webapp_root}"
  }

  dynamic "origin" {
    for_each = var.polly_proxy_enabled ? [1] : []

    content {
      domain_name = "polly.${var.polly_region}.amazonaws.com"
      origin_id   = "polly-api"

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  dynamic "origin" {
    for_each = var.translate_proxy_enabled ? [1] : []

    content {
      domain_name = "translate.${var.translate_region}.amazonaws.com"
      origin_id   = "translate-api"

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  default_cache_behavior {
    target_origin_id       = "webapp-s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    cache_policy_id        = aws_cloudfront_cache_policy.webapp_disabled.id
    compress               = true
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.polly_proxy_enabled ? [1] : []

    content {
      path_pattern             = "/amazon-polly-proxy/*"
      target_origin_id         = "polly-api"
      viewer_protocol_policy   = "https-only"
      allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods           = ["GET", "HEAD"]
      cache_policy_id          = aws_cloudfront_cache_policy.polly_api[0].id
      origin_request_policy_id = aws_cloudfront_origin_request_policy.polly_api[0].id
      compress                 = true

      function_association {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.polly_url_rewrite[0].arn
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.translate_proxy_enabled ? [1] : []

    content {
      path_pattern             = "/amazon-translate-proxy/*"
      target_origin_id         = "translate-api"
      viewer_protocol_policy   = "https-only"
      allowed_methods          = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
      cached_methods           = ["GET", "HEAD"]
      cache_policy_id          = aws_cloudfront_cache_policy.translate_api[0].id
      origin_request_policy_id = aws_cloudfront_origin_request_policy.translate_api[0].id
      compress                 = true

      function_association {
        event_type   = "viewer-request"
        function_arn = aws_cloudfront_function.translate_url_rewrite[0].arn
      }
    }
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 60
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = var.common_tags
}
