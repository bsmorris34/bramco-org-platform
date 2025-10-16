# Move existing accounts to specified OUs
# This approach requires importing existing accounts first
resource "aws_organizations_account" "this" {
  for_each = var.account_assignments

  # Account will be imported with actual values
  name      = "temp-placeholder"
  email     = "temp@placeholder.com"
  parent_id = each.value.ou_id

  lifecycle {
    ignore_changes = [
      name,
      email,
      iam_user_access_to_billing,
      role_name,
      tags
    ]
  }
}
