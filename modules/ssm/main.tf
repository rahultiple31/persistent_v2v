resource "aws_ssm_parameter" "this" {
  for_each = var.parameters

  name      = "${var.ssm_hierarchy}${each.key}"
  type      = "String"
  value     = each.value
  overwrite = true
  tags      = var.common_tags
}
