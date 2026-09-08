data "aws_region" "current" {}

locals {
  name_prefix = lower(replace("${var.project_name}-${var.environment}-${var.app_name}", "_", "-"))

  common_tags = merge(var.common_tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Platform    = "Amazon Connect V2V Translation"
    Application = var.app_name
  })

  frontend_config = {
    backendRegion         = data.aws_region.current.name
    identityPoolId        = module.cognito.identity_pool_id
    userPoolId            = module.cognito.user_pool_id
    userPoolWebClientId   = module.cognito.user_pool_web_client_id
    cognitoDomainURL      = module.cognito.cognito_domain_url
    connectInstanceURL    = var.connect_instance_url
    connectInstanceRegion = var.connect_instance_region
    transcribeRegion      = var.transcribe_region
    translateRegion       = var.translate_region
    translateProxyEnabled = tostring(var.translate_proxy_enabled)
    pollyRegion           = var.polly_region
    pollyProxyEnabled     = tostring(var.polly_proxy_enabled)
  }

  ssm_parameters = {
    cognitoDomainPrefix   = var.cognito_domain_prefix
    cognitoCallbackUrls   = join(",", var.cognito_callback_urls)
    cognitoLogoutUrls     = join(",", var.cognito_logout_urls)
    connectInstanceURL    = var.connect_instance_url
    connectInstanceRegion = var.connect_instance_region
    transcribeRegion      = var.transcribe_region
    translateRegion       = var.translate_region
    translateProxyEnabled = tostring(var.translate_proxy_enabled)
    pollyRegion           = var.polly_region
    pollyProxyEnabled     = tostring(var.polly_proxy_enabled)
  }
}

module "s3" {
  source = "../../modules/s3"

  app_name             = var.app_name
  webapp_root_prefix   = var.webapp_root_prefix
  deploy_webapp_assets = var.deploy_webapp_assets
  webapp_dist_path     = var.webapp_dist_path
  frontend_config      = local.frontend_config
  common_tags          = local.common_tags
}

module "cloudfront" {
  source = "../../modules/cloudfront"

  name_prefix                        = local.name_prefix
  app_name                           = var.app_name
  webapp_root_prefix                 = var.webapp_root_prefix
  webapp_bucket_regional_domain_name = module.s3.webapp_bucket_regional_domain_name
  webapp_log_bucket_domain_name      = module.s3.webapp_log_bucket_domain_name
  polly_region                       = var.polly_region
  polly_proxy_enabled                = var.polly_proxy_enabled
  translate_region                   = var.translate_region
  translate_proxy_enabled            = var.translate_proxy_enabled
  common_tags                        = local.common_tags
}

module "cognito" {
  source = "../../modules/cognito"

  app_name              = var.app_name
  frontend_client_name  = var.frontend_client_name
  cognito_domain_prefix = var.cognito_domain_prefix
  callback_urls         = var.cognito_callback_urls
  logout_urls           = var.cognito_logout_urls
  common_tags           = local.common_tags
}

module "iam" {
  source = "../../modules/iam"

  name_prefix      = local.name_prefix
  identity_pool_id = module.cognito.identity_pool_id
  common_tags      = local.common_tags
}

module "ssm" {
  source = "../../modules/ssm"

  ssm_hierarchy = var.ssm_hierarchy
  parameters    = local.ssm_parameters
  common_tags   = local.common_tags
}
