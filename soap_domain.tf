# ---------------------------------------------------------------------------
# soap_domain.tf  →  real-time-insurance-infra
#
# Route 53 resources use provider = aws.networkacc because devkyfb.com is
# registered in the network account, not the destination account.
#
# The S3 truststore bucket uses the default provider (destination account)
# because it is an application resource, not a DNS resource.
# ---------------------------------------------------------------------------

# ── Route 53 hosted zone lookup (network account) ───────────────────────────

data "aws_route53_zone" "devkyfb" {
  provider = aws.networkacc
  name         = var.soap_api_hosted_zone
  private_zone = false
}

# ── S3 bucket for mTLS truststore (destination account) ─────────────────────
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

# ── Route 53 CNAME — subdomain → API Gateway regional endpoint ──────────────
# Uses networkacc provider because the hosted zone lives in the network account.

resource "aws_route53_record" "soap_api" {
  provider = aws.networkacc
  zone_id = data.aws_route53_zone.devkyfb.zone_id
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
  description = "Upload your mTLS CA cert PEM to this bucket as truststore.pem, then uncomment mtls_truststore_uri in api.tf."
  value       = "s3://${aws_s3_bucket.soap_api_truststore.bucket}/truststore.pem"
}
