# Get SSO instance
data "aws_ssoadmin_instances" "main" {}

# Create permission sets
resource "aws_ssoadmin_permission_set" "this" {
  for_each = var.permission_sets

  name             = each.value.name
  description      = each.value.description
  instance_arn     = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  session_duration = lookup(each.value, "session_duration", "PT8H")
}

# Attach managed policies to permission sets
resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = {
    for combo in flatten([
      for ps_key, ps_value in var.permission_sets : [
        for policy in ps_value.managed_policies : {
          key                = "${ps_key}-${replace(policy, ":", "-")}"
          permission_set_key = ps_key
          policy_arn         = policy
        }
      ]
    ]) : combo.key => combo
  }

  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  managed_policy_arn = each.value.policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set_key].arn
}

# Create inline policies for permission sets
resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each = {
    for combo in flatten([
      for ps_key, ps_value in var.permission_sets : [
        for policy_name, policy_doc in lookup(ps_value, "inline_policies", {}) : {
          key                = "${ps_key}-${policy_name}"
          permission_set_key = ps_key
          policy_document    = policy_doc
        }
      ]
    ]) : combo.key => combo
  }

  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set_key].arn
  inline_policy      = each.value.policy_document
}

# Create account assignments
resource "aws_ssoadmin_account_assignment" "this" {
  for_each = var.account_assignments

  instance_arn       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set_key].arn
  principal_id       = each.value.principal_id
  principal_type     = each.value.principal_type
  target_id          = each.value.target_id
  target_type        = each.value.target_type
}