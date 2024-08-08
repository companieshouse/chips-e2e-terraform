variable "aws_account" {
  type        = string
  description = "The name of the AWS account in which resources will be provisioned."
}

variable "region" {
  type        = string
  description = "The AWS region in which resources will be created."
}

variable "environment" {
  type        = string
  description = "The environment name to be used when provisioning AWS resources."
}

variable "shared_services_enabled" {
  type        = bool
  description = "A boolean value representing whether to enable Shared Services data buckets or not."
  default     = false
}

variable "shared_services_read_only_principals" {
  type        = list(string)
  description = "An optional list of principal ARNs which will be granted read-only access to Shared Services data buckets and usage of the KMS key for object decryption. Applicable only when 'shared_services_enabled' is true."
  default     = []
}

variable "ami_version_pattern" {
  type        = string
  description = "The pattern to use when filtering for AMI version by name."
  default     = "*"
}

variable "instance_count" {
  type        = number
  description = "The number EC2 instances to create."
  default     = 1
}

variable "root_volume_size" {
  type        = number
  description = "The size of the root volume in gibibytes (GiB)."
  default     = 20
}

variable "instance_type" {
  type        = string
  description = "The instance type to use for EC2 instances."
  default     = "t3.small"
}

variable "application_subnet_pattern" {
  type        = string
  description = "The pattern to use when filtering for application subnets by 'Name' tag."
}

variable "dns_zone_suffix" {
  type        = string
  description = "The common DNS hosted zone suffix used across accounts."
  default     = "development.aws.internal"
}

variable "default_log_retention_in_days" {
  type        = number
  description = "The default log retention period in days to be used for CloudWatch log groups."
}

variable "service" {
  type        = string
  description = "The service name to be used when creating AWS resources."
  default     = "chips-e2e"
}

variable "service_subtype" {
  type        = string
  description = "The service subtype name to be used when creating AWS resources."
}

variable "team" {
  type        = string
  description = "The team name for ownership of this service."
  default     = "Development"
}
