output "common_tags" {
  description = "Common tags for all resources"
  value = merge({
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    ManagedBy   = "terraform"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  }, var.additional_tags)
}