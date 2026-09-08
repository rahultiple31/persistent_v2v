environment             = "dev"
project_name            = "abbvie"
aws_region              = "us-east-1"
cognito_domain_prefix   = "abbvie-dev-connect-v2v"
cognito_callback_urls   = ["https://localhost:5173"]
cognito_logout_urls     = ["https://localhost:5173"]
connect_instance_url    = "https://test.my.connect.aws"
connect_instance_region = "us-east-1"
transcribe_region       = "us-east-1"
translate_region        = "us-east-1"
translate_proxy_enabled = true
polly_region            = "us-east-1"
polly_proxy_enabled     = true
deploy_webapp_assets    = true

common_tags = {
  CostCenter = "contact-center"
  Owner      = "platform-engineering"
}
