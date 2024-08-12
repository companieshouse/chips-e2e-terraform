locals {
  application_subnet_ids_by_az = values(zipmap(data.aws_subnet.application[*].availability_zone, data.aws_subnet.application[*].id))

  common_tags = {
    Environment    = var.environment
    Service        = var.service
    ServiceSubType = var.service_subtype
    Team           = var.team
  }

  common_resource_name = "${var.environment}-${var.service_subtype}"
  dns_zone             = "${var.environment}.${var.dns_zone_suffix}"

  security_s3_data            = data.vault_generic_secret.security_s3_buckets.data
  session_manager_bucket_name = local.security_s3_data.session-manager-bucket-name

  security_kms_keys_data = data.vault_generic_secret.security_kms_keys.data
  ssm_kms_key_id         = local.security_kms_keys_data.session-manager-kms-key-arn

  account_ids_secrets = jsondecode(data.vault_generic_secret.account_ids.data_json)
  chips_e2e_pilot_ami_owner_id = local.account_ids_secrets["shared-services"]

  shared_services_count       = var.shared_services_enabled ? 1 : 0
  shared_services_bucket_name = "shared-services.${var.service_subtype}.${var.service}.${var.aws_account}.ch.gov.uk"
  shared_services_bucket_read_only_principals = (
    var.shared_services_enabled ?
    jsondecode(data.vault_generic_secret.shared_services[0].data.s3_bucket_read_only_principals) :
    []
  )

  instance_profile_writable_buckets = flatten([
    local.session_manager_bucket_name,
    var.shared_services_enabled ? [local.shared_services_bucket_name] : []
  ])

  instance_profile_kms_key_access_ids = flatten([
    local.ssm_kms_key_id,
    var.shared_services_enabled ? [aws_kms_key.chips_e2e[0].key_id] : []
  ])

  logs_kms_key_id            = data.vault_generic_secret.kms_keys.data["logs"]
  kms_key_administrator_arns = concat(tolist(data.aws_iam_roles.sso_administrator.arns), [data.aws_iam_user.concourse.arn])

  iboss_cidr = "10.40.250.0/24"

}
