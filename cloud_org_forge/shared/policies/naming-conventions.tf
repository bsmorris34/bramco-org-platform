locals {
  naming_convention = {
    environment_prefixes = {
      dev     = "dev"
      staging = "stg"
      prod    = "prd"
    }
    
    resource_suffixes = {
      storage_account = "sa"
      resource_group  = "rg"
      key_vault      = "kv"
      app_service    = "app"
    }
    
    separator = "-"
  }
}

# Example usage:
# resource_name = "${local.naming_convention.environment_prefixes[var.environment]}${local.naming_convention.separator}${var.project_name}${local.naming_convention.separator}${local.naming_convention.resource_suffixes.storage_account}"