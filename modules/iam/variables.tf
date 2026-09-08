variable "name_prefix" {
  description = "Name prefix for IAM roles and policies."
  type        = string
}

variable "identity_pool_id" {
  description = "Cognito Identity Pool ID used in role trust policies."
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to supported resources."
  type        = map(string)
  default     = {}
}
