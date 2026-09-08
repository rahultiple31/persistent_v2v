variable "ssm_hierarchy" {
  description = "SSM Parameter Store hierarchy used by the V2V solution."
  type        = string
}

variable "parameters" {
  description = "SSM string parameters to create under ssm_hierarchy."
  type        = map(string)
}

variable "common_tags" {
  description = "Common tags applied to supported resources."
  type        = map(string)
  default     = {}
}
