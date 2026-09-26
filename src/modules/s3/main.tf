data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  audio_bucket_name  = lower("${data.aws_caller_identity.current.account_id}-${var.audio_bucket_base}-${data.aws_region.current.region}")
  document_bucket_name  = lower("${data.aws_caller_identity.current.account_id}-${var.document_bucket_base}-${data.aws_region.current.region}")
  deploy_bucket_name = lower("${data.aws_caller_identity.current.account_id}-${var.deploy_bucket_base}-${data.aws_region.current.region}")

  force_destroy = var.removal_policy == "destroy" ? true : false
}

# 🪣 Audio Bucket
resource "aws_s3_bucket" "audio" {
  bucket        = local.audio_bucket_name
  force_destroy = local.force_destroy
}

resource "aws_s3_bucket_server_side_encryption_configuration" "audio" {
  bucket = aws_s3_bucket.audio.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "audio" {
  bucket = aws_s3_bucket.audio.id

  versioning_configuration {
    status = var.versioned ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "audio" {
  bucket = aws_s3_bucket.audio.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_cors_configuration" "audio" {
  bucket = aws_s3_bucket.audio.id

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers = cors_rule.value.AllowedHeaders
      allowed_methods = cors_rule.value.AllowedMethods
      allowed_origins = cors_rule.value.AllowedOrigins
      expose_headers  = lookup(cors_rule.value, "ExposeHeaders", null)
      max_age_seconds = lookup(cors_rule.value, "MaxAgeSeconds", null)
    }
  }
}


# 🪣 Document Bucket (Future Use)
resource "aws_s3_bucket" "document" {
  bucket        = local.document_bucket_name
  force_destroy = local.force_destroy

 
}

resource "aws_s3_bucket_server_side_encryption_configuration" "document" {
  bucket = aws_s3_bucket.document.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "document" {
  bucket = aws_s3_bucket.document.id

  versioning_configuration {
    status = var.versioned ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "document" {
  bucket = aws_s3_bucket.document.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_cors_configuration" "document" {
  bucket = aws_s3_bucket.document.id

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers = cors_rule.value.AllowedHeaders
      allowed_methods = cors_rule.value.AllowedMethods
      allowed_origins = cors_rule.value.AllowedOrigins
      expose_headers  = lookup(cors_rule.value, "ExposeHeaders", null)
      max_age_seconds = lookup(cors_rule.value, "MaxAgeSeconds", null)
    }
  }
}

# 🪣 Deploy Bucket
resource "aws_s3_bucket" "deploy" {
  bucket        = local.deploy_bucket_name
  force_destroy = local.force_destroy
}

resource "aws_s3_bucket_server_side_encryption_configuration" "deploy" {
  bucket = aws_s3_bucket.deploy.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "deploy" {
  bucket = aws_s3_bucket.deploy.id

  versioning_configuration {
    status = "Suspended"
  }
}

resource "aws_s3_bucket_public_access_block" "deploy" {
  bucket = aws_s3_bucket.deploy.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

