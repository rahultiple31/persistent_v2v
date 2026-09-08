output "connect_v2v_translation" {
  description = "Amazon Connect V2V translation solution outputs."
  value = {
    backend_region                      = data.aws_region.current.name
    identity_pool_id                    = module.cognito.identity_pool_id
    user_pool_id                        = module.cognito.user_pool_id
    user_pool_web_client_id             = module.cognito.user_pool_web_client_id
    cognito_domain_url                  = module.cognito.cognito_domain_url
    authenticated_role_arn              = module.iam.authenticated_role_arn
    unauthenticated_role_arn            = module.iam.unauthenticated_role_arn
    webapp_bucket_name                  = module.s3.webapp_bucket_name
    webapp_log_bucket_name              = module.s3.webapp_log_bucket_name
    cloudfront_distribution_id          = module.cloudfront.cloudfront_distribution_id
    cloudfront_distribution_domain_name = module.cloudfront.cloudfront_distribution_domain_name
    webapp_url                          = module.cloudfront.webapp_url
    ssm_parameter_names                 = module.ssm.parameter_names
  }
}
