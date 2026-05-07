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
    },
    {
      path       = "/sample"
      method     = "GET"
      lambda_arn = module.sample_lambda.lambda_function_arn
    }
  ]
}
