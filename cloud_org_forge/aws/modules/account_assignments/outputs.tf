output "account_assignments" {
  description = "Map of account assignments"
  value = {
    for k, v in aws_organizations_account.this : k => {
      account_id = v.id
      ou_id      = v.parent_id
    }
  }
}