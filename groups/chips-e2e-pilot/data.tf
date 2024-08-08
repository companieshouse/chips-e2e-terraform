data "aws_ec2_managed_prefix_list" "shared_services_management" {
  name = "shared-services-management-cidrs"
}

data "aws_iam_policy_document" "fil" {
  count = local.shared_services_count

  statement {
    sid = "EnableIAMPolicies"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid = "AllowAccessForKeyAdministrators"

    principals {
      type        = "AWS"
      identifiers = local.kms_key_administrator_arns
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid = "AllowDecryptionOperationsForThesePrincipals"

    principals {
      type        = "AWS"
      identifiers = local.shared_services_bucket_read_only_principals
    }

    actions = ["kms:Decrypt"]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "shared_services_bucket" {
  count = local.shared_services_count

  statement {
    sid = "AllowListBucketFromThesePrincipals"

    principals {
      type        = "AWS"
      identifiers = local.shared_services_bucket_read_only_principals
    }

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.shared_services[0].arn
    ]
  }

  statement {
    sid = "AllowReadAccessFromThesePrincipals"

    principals {
      type        = "AWS"
      identifiers = local.shared_services_bucket_read_only_principals
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.shared_services[0].arn}/*",
    ]
  }

  statement {
    sid = "DenyPutObjectWithInvalidEncryptionHeader"

    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.shared_services[0].arn}/*"
    ]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["aws:kms"]
    }
  }

  statement {
    sid = "DenyPutObjectWithMissingEncryptionHeader"

    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.shared_services[0].arn}/*"
    ]

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["true"]
    }
  }

  statement {
    sid = "DenyPutObjectWithInvalidEncryptionKeyHeader"

    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.shared_services[0].arn}/*"
    ]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = [aws_kms_key.fil[0].arn]
    }
  }

  statement {
    sid = "DenyPutObjectWithMissingEncryptionKeyHeader"

    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.shared_services[0].arn}/*"
    ]

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = ["true"]
    }
  }
}

data "aws_route53_zone" "private_zone" {
  name   = local.dns_zone
  vpc_id = data.aws_vpc.heritage.id
}

data "aws_vpc" "heritage" {
  filter {
    name   = "tag:Name"
    values = ["vpc-heritage-${var.environment}"]
  }
}

data "vault_generic_secret" "internal_cidrs" {
  path = "aws-accounts/network/internal_cidr_ranges"
}

data "aws_subnets" "application" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.heritage.id]
  }

  filter {
    name   = "tag:Name"
    values = [var.application_subnet_pattern]
  }
}

data "aws_subnet" "application" {
  count = length(data.aws_subnets.application.ids)
  id    = tolist(data.aws_subnets.application.ids)[count.index]
}

data "aws_ami" "amzn2-base-ami" {
  most_recent = true
  name_regex  = "amzn2-base-\\d.\\d.\\d"

  filter {
    name   = "name"
    values = ["amzn2-base-${var.ami_version_pattern}"]
  }
}

data "vault_generic_secret" "account_ids" {
  path = "aws-accounts/account-ids"
}

data "vault_generic_secret" "kms_keys" {
  path = "aws-accounts/${var.aws_account}/kms"
}

data "vault_generic_secret" "security_s3_buckets" {
  path = "aws-accounts/security/s3"
}

data "vault_generic_secret" "security_kms_keys" {
  path = "aws-accounts/security/kms"
}
