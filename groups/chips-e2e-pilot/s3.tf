resource "aws_s3_bucket" "shared-services" {
  count = local.shared_services_count

  bucket = local.shared_services_bucket_name
}

resource "aws_s3_bucket_server_side_encryption_configuration" "shared_services" {
  count = local.shared_services_count

  bucket = aws_s3_bucket.shared_services[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.chips_e2e[0].arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "shared_services" {
  count = local.shared_services_count

  bucket = aws_s3_bucket.shared_services[0].id
  policy = data.aws_iam_policy_document.shared_services_bucket[0].json
}

resource "aws_s3_bucket_lifecycle_configuration" "shared_services" {
  count = local.shared_services_count

  bucket = aws_s3_bucket.shared_services[0].id

  rule {
    id = "shared-services-expiration"

    filter {}

    expiration {
      days = 14
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "shared_services" {
  count = local.shared_services_count

  bucket = aws_s3_bucket.shared_services[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
