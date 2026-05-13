# ---------------------------------------------------------------------------
# soap_domain.tf  →  real-time-insurance-infra
#
# ACM certificate is created manually in the AWS console and its ARN is
# passed in via var.soap_api_certificate_arn in dev.tfvars.
#
# This file manages:
#   1. Route 53 hosted zone lookup
#   2. S3 bucket for mTLS truststore (upload CA cert here when ready)
#   3. Route 53 CNAME pointing soap-api-dev.devkyfb.com → API Gateway
# ---------------------------------------------------------------------------

# ── 1. Look up the existing devkyfb.com hosted zone ─────────────────────────

data "aws_route53_zone" "soap_api" {
  name         = var.soap_api_hosted_zone
  private_zone = false
}

# ── 2. S3 bucket for mTLS truststore ────────────────────────────────────────
# Upload your CA certificate here when you are ready to enable mTLS:
#   aws s3 cp ca.crt s3://<bucket-name>/truststore.pem

resource "aws_s3_bucket" "soap_api_truststore" {
  bucket = "${var.application_name}-${var.env_tier}-soap-api-truststore"

  tags = {
    Name = "${var.application_name}-${var.env_tier}-soap-api-truststore"
  }
}

resource "aws_s3_bucket_versioning" "soap_api_truststore" {
  bucket = aws_s3_bucket.soap_api_truststore.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "soap_api_truststore" {
  bucket                  = aws_s3_bucket.soap_api_truststore.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ── 3. Route 53 CNAME — subdomain → API Gateway regional endpoint ────────────
# Created after the custom domain is live in the module.

resource "aws_route53_record" "soap_api" {
  zone_id = data.aws_route53_zone.soap_api.zone_id
  name    = var.soap_api_domain_name
  type    = "CNAME"
  ttl     = 300
  records = [module.soap_api_gateway.custom_domain_target]
}

# ── Outputs ──────────────────────────────────────────────────────────────────

output "soap_api_url" {
  description = "Public URL for the SOAP API once DNS propagates."
  value       = "https://${var.soap_api_domain_name}/soap"
}

output "soap_api_truststore_bucket" {
  description = "Upload your mTLS CA cert PEM to this bucket as truststore.pem then uncomment mtls_truststore_uri in api.tf."
  value       = "s3://${aws_s3_bucket.soap_api_truststore.bucket}/truststore.pem"
}
