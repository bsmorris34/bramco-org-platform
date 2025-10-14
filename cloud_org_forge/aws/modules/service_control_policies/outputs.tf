output "policy_ids" {
  description = "Map of created policy IDs"
  value = {
    for k, v in aws_organizations_policy.this : k => v.id
  }
}

output "policy_attachments" {
  description = "Map of policy attachments"
  value = {
    for k, v in aws_organizations_policy_attachment.this : k => {
      policy_id = v.policy_id
      target_id = v.target_id
    }
  }
}
