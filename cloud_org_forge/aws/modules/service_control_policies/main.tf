# Create Service Control Policies
resource "aws_organizations_policy" "this" {
  for_each = var.policies

  name        = each.value.name
  description = each.value.description
  content     = each.value.policy_document
  type        = "SERVICE_CONTROL_POLICY"
}

# Attach policies to organizational units
resource "aws_organizations_policy_attachment" "this" {
  for_each = var.policy_attachments

  policy_id = aws_organizations_policy.this[each.value.policy_key].id
  target_id = each.value.target_id
}
