variable "application_name" {
  description = "Name of application"
  type        = string
  default     = "realtimeinsurance"
}

variable "env_tier" {
  description = "Logical environment name (dev, qa, uat, perf, prod, etc.)"
  type        = string
}

variable "destination_account_id" {
  description = "AWS Account ID to deploy to."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the vpc resources will be deployed."
  type        = string
}

variable "entra_audience" {
  description = "Logical environment name (dev, qa, uat, perf, prod, etc.)"
  type        = string
}

variable "lambda_subnet_ids" {
  description = "Subnet IDs for the Lambda ENIs."
  type        = list(string)
}

variable "aurora_subnet_ids" {
  description = "Subnet IDs for the Aurora DB cluster."
  type        = list(string)
}

variable "replicas" {
  description = "Number of Aurora read replicas (readers). Applies to both provisioned and Serverless v2."
  type        = number
  default     = 1
}

variable "instance_class" {
  description = "Instance class to use when db_engine_mode is provisioned (example: db.r6g.large). Ignored for Serverless v2."
  type        = string
  default     = "db.r6g.large"
}

variable "db_engine_mode" {
  description = "provisioned or serverless (serverless means Aurora Serverless v2 in this configuration)"
  type        = string
  validation {
    condition     = contains(["provisioned", "serverless"], var.db_engine_mode)
    error_message = "db_engine_mode must be 'provisioned' or 'serverless'."
  }
}

variable "serverless_v2_min_acu" {
  description = "Minimum Aurora Capacity Units (ACUs) for Serverless v2."
  type        = number
  default     = 0.5
}

variable "serverless_v2_max_acu" {
  description = "Maximum Aurora Capacity Units (ACUs) for Serverless v2."
  type        = number
  default     = 2
}

variable "soap_api_certificate_arn" {
  description = "ARN of the ACM certificate for soap-api-dev.devkyfb.com. Created manually in the AWS console — copy the ARN from ACM and paste it into dev.tfvars."
  type        = string
}

variable "soap_api_domain_name" {
  description = "Full subdomain for the SOAP API (e.g. soap-api-dev.devkyfb.com)."
  type        = string
}

variable "soap_api_hosted_zone" {
  description = "The Route 53 hosted zone the subdomain belongs to (e.g. devkyfb.com)."
  type        = string
}