
resource "aws_kms_key" "chips_e2e" {
  count = local.shared_services_count

  description         = "KMS key for CHIPS E2E services"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.chips_e2e[0].json

  tags = merge(local.common_tags, {
    Name = local.common_resource_name
  })
}

resource "aws_kms_alias" "chips_e2e" {
  count = local.shared_services_count

  name          = "alias/${local.common_resource_name}"
  target_key_id = aws_kms_key.chips_e2e[0].key_id
}
