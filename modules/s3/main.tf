data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  app_name_lower   = lower(var.app_name)
  webapp_dist_path = var.webapp_dist_path == null ? abspath("${path.root}/../../webapp/dist") : abspath(var.webapp_dist_path)
  webapp_files     = var.deploy_webapp_assets ? fileset(local.webapp_dist_path, "**") : []

  content_types = {
    css   = "text/css"
    gif   = "image/gif"
    html  = "text/html"
    ico   = "image/x-icon"
    jpeg  = "image/jpeg"
    jpg   = "image/jpeg"
    js    = "text/javascript"
    json  = "application/json"
    map   = "application/json"
    mp3   = "audio/mpeg"
    png   = "image/png"
    svg   = "image/svg+xml"
    txt   = "text/plain"
    wav   = "audio/wav"
    webp  = "image/webp"
    woff  = "font/woff"
    woff2 = "font/woff2"
  }
}

resource "aws_s3_bucket" "webapp" {
  bucket        = "${local.app_name_lower}-webappbucket-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  force_destroy = true
  tags          = var.common_tags
}

resource "aws_s3_bucket" "webapp_logs" {
  bucket        = "${local.app_name_lower}-webapplogbucket-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  force_destroy = true
  tags          = var.common_tags
}

resource "aws_s3_bucket_public_access_block" "webapp" {
  bucket = aws_s3_bucket.webapp.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "webapp_logs" {
  bucket = aws_s3_bucket.webapp_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "webapp" {
  bucket = aws_s3_bucket.webapp.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "webapp_logs" {
  bucket = aws_s3_bucket.webapp_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "webapp" {
  bucket = aws_s3_bucket.webapp.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "webapp_logs" {
  bucket = aws_s3_bucket.webapp_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "webapp_logs" {
  bucket = aws_s3_bucket.webapp_logs.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "webapp_logs" {
  bucket = aws_s3_bucket.webapp_logs.id
  acl    = "log-delivery-write"

  depends_on = [
    aws_s3_bucket_ownership_controls.webapp_logs,
    aws_s3_bucket_public_access_block.webapp_logs
  ]
}

data "aws_iam_policy_document" "webapp_bucket" {
  statement {
    sid     = "AllowCloudFrontServicePrincipalReadOnly"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    resources = ["${aws_s3_bucket.webapp.arn}/${trimsuffix(var.webapp_root_prefix, "/")}/*"]
  }

  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      aws_s3_bucket.webapp.arn,
      "${aws_s3_bucket.webapp.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

data "aws_iam_policy_document" "webapp_logs_bucket" {
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = [
      aws_s3_bucket.webapp_logs.arn,
      "${aws_s3_bucket.webapp_logs.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "webapp" {
  bucket = aws_s3_bucket.webapp.id
  policy = data.aws_iam_policy_document.webapp_bucket.json
}

resource "aws_s3_bucket_policy" "webapp_logs" {
  bucket = aws_s3_bucket.webapp_logs.id
  policy = data.aws_iam_policy_document.webapp_logs_bucket.json
}

resource "aws_s3_object" "frontend_config" {
  bucket       = aws_s3_bucket.webapp.id
  key          = "${var.webapp_root_prefix}frontend-config.js"
  content      = "window.WebappConfig = ${jsonencode(var.frontend_config)}"
  content_type = "text/javascript"
  etag         = md5("window.WebappConfig = ${jsonencode(var.frontend_config)}")
  tags         = var.common_tags
}

resource "aws_s3_object" "webapp_assets" {
  for_each = {
    for file_path in local.webapp_files : file_path => file_path
    if !endswith(file_path, "/")
  }

  bucket       = aws_s3_bucket.webapp.id
  key          = "${var.webapp_root_prefix}${each.value}"
  source       = "${local.webapp_dist_path}/${each.value}"
  content_type = lookup(local.content_types, lower(element(reverse(split(".", each.value)), 0)), "binary/octet-stream")
  etag         = filemd5("${local.webapp_dist_path}/${each.value}")
  tags         = var.common_tags
}
