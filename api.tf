module "api_gateway" {
  source = "git::https://github.com/schatala/tf-module-api-gateway.git?ref=v1.0.0"

  name          = "${var.application_name}-${var.env_tier}-api-gateway"
  is_production = false

  jwt_audience = ["${var.entra_audience}"]

  routes = [
    {
      path       = "/hello"
      method     = "GET"
      lambda_arn = module.hello_lambda.lambda_function_arn
    }
  ]
}

# ── SOAP API gateway ────────────────────────────────────────────────────────
# Uses the existing sample_lambda as the backend.
# Pinned to v1.1.0 of the module which adds the mTLS / custom domain
# resources (dormant until domain_name is passed in).
#
# To enable mTLS later, add these three arguments to this module block:
#   domain_name              = "soap-api.mvsolutions.com"
#   regional_certificate_arn = "arn:aws:acm:us-east-1:XXXX:certificate/XXXX"
#   mtls_truststore_uri      = "s3://your-bucket/truststore.pem"
# ---------------------------------------------------------------------------
module "soap_api_gateway" {
  source        = "git::https://github.com/schatala/tf-module-api-gateway.git?ref=v1.1.0"
  name          = "${var.application_name}-${var.env_tier}-soap-api-gateway"
  is_production = false
  jwt_audience  = ["${var.entra_audience}"]

  custom_ip_whitelist = [
    "192.0.2.10/32",   # replace with real SOAP consumer IP
    "192.0.2.20/32",   # replace with real SOAP consumer IP
    "198.51.100.5/32", # replace with real SOAP consumer IP
  ]

  routes = [
    {
      path       = "/soap"
      method     = "GET"
      lambda_arn = module.sample_lambda.lambda_function_arn
    }
  ]
}
