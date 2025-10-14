output "permission_set_arns" {
  description = "Map of permission set ARNs"
  value = {
    for k, v in aws_ssoadmin_permission_set.this : k => v.arn
  }
}

output "permission_set_ids" {
  description = "Map of permission set IDs"
  value = {
    for k, v in aws_ssoadmin_permission_set.this : k => v.id
  }
}

output "account_assignments" {
  description = "Map of account assignments"
  value = {
    for k, v in aws_ssoadmin_account_assignment.this : k => {
      permission_set_arn = v.permission_set_arn
      principal_id       = v.principal_id
      target_id          = v.target_id
    }
  }
}