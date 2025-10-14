output "organization_id" {
  description = "AWS Organization ID"
  value       = data.aws_organizations_organization.current.id
}

output "organization_root_id" {
  description = "AWS Organization root ID"
  value       = data.aws_organizations_organization.current.roots[0].id
}

output "organizational_units" {
  description = "Created organizational units"
  value       = module.organizational_units.all_organizational_units
}

output "security_ou_id" {
  description = "Security OU ID for account placement"
  value       = module.organizational_units.organizational_units["security"].id
}

output "workloads_ou_ids" {
  description = "Workload OU IDs for account placement"
  value = {
    dev     = module.organizational_units.nested_organizational_units["dev_workloads"].id
    staging = module.organizational_units.nested_organizational_units["staging_workloads"].id
    prod    = module.organizational_units.nested_organizational_units["prod_workloads"].id
  }
}

output "sandbox_ou_id" {
  description = "Sandbox OU ID for account placement"
  value       = module.organizational_units.organizational_units["sandbox"].id
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions IAM role"
  value       = module.github_oidc.github_actions_role_arn
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = module.github_oidc.oidc_provider_arn
}