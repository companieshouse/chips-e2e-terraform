data "aws_ec2_managed_prefix_list" "shared_services_management" {
  name = "shared-services-management-cidrs"
}


data "aws_route53_zone" "chips-e2e-pilot" {
  name   = local.dns_zone
  vpc_id = data.aws_vpc.finance.id
}

data "aws_vpc" "finance" {
  filter {
    name   = "tag:Name"
    values = ["vpc-finance-${var.environment}"]
  }
}

data "vault_generic_secret" "internal_cidrs" {
  path = "aws-accounts/network/internal_cidr_ranges"
}

data "aws_subnets" "application" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.finance.id]
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

data "aws_ami" "chips-e2e-pilot-base-ami" {
  owners      = [var.ami_owner_id]
  most_recent = true
  name_regex  = "^${var.service_subtype}-${var.service}-ami-\\d.\\d.\\d"

  filter {
    name   = "name"
    values = ["${var.service_subtype}-${var.service}-ami-${var.ami_version_pattern}"]
  }
}

data "cloudinit_config" "config" {
  count = var.instance_count

  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/cloud-init/templates/system-config.yml.tpl", {})
  }

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init/templates/bootstrap-commands.yml.tpl", {
      instance_hostname = "${var.service_subtype}-${var.service}-${var.environment}-${count.index + 1}"
      lvm_block_devices = var.lvm_block_devices
    })
  }
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
