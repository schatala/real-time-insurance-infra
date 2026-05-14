terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40"
    }
  }
  backend "s3" {
    bucket = "kfb-github-terraform-state"
    key    = "real-time-insurance-infra/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.destination_account_id}:role/kfb-terraform-assume-role"
  }
  default_tags {
    tags = {
      "application_name"      = "realtimeinsurance"
      "terraform"             = "true"
      "source"                = "github.com/kfbmic/real-time-insurance-infra"
      "created_by"            = "PlatformEngineering@kyfb.com"
      "requested_by"          = "PMOGroup@kyfb.com"
      "owned_by"              = "CloudOps@kyfb.com"
      "business_ops_category" = "POL"
    }
  }
}

# ── network account provider — for Route 53 resources in devkyfb.com ────────
# devkyfb.com is registered in a separate network account.
# All Route 53 resources in soap_domain.tf use provider = aws.networkacc.
provider "aws" {
  alias  = "networkacc"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::${var.network_account_id}:role/kfb-terraform-assume-role"
  }

  default_tags {
    tags = {
      "application_name"     = "realtimeinsurance"
      "terraform"            = "true"
      "source"               = "github.com/kfbmic/real-time-insurance-infra"
      "created_by"           = "PlatformEngineering@kyfb.com"
      "requested_by"         = "PMOGroup@kyfb.com"
      "owned_by"             = "CloudOps@kyfb.com"
      "business_ops_category" = "POL"
    }
  }
}