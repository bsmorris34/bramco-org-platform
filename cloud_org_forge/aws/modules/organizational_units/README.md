# AWS Organizational Units Module

This module creates AWS Organization Units (OUs) with support for nested structures.

## Usage

```hcl
module "organizational_units" {
  source = "../../modules/organizational_units"

  organizational_units = {
    security = {
      name      = "Security"
      parent_id = data.aws_organizations_organization.current.roots[0].id
      tags = {
        Purpose = "Security and compliance"
      }
    }
    workloads = {
      name      = "Workloads"
      parent_id = data.aws_organizations_organization.current.roots[0].id
      tags = {
        Purpose = "Application workloads"
      }
    }
  }

  nested_organizational_units = {
    dev_workloads = {
      name          = "Development"
      parent_ou_key = "workloads"
      tags = {
        Environment = "development"
      }
    }
    prod_workloads = {
      name          = "Production"
      parent_ou_key = "workloads"
      tags = {
        Environment = "production"
      }
    }
  }

  common_tags = {
    ManagedBy = "terraform"
    Project   = "bramco1-org"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| organizational_units | Map of organizational units to create | `map(object)` | `{}` | no |
| nested_organizational_units | Map of nested OUs to create under main OUs | `map(object)` | `{}` | no |
| common_tags | Common tags to apply to all OUs | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| organizational_units | Map of created organizational units |
| nested_organizational_units | Map of created nested organizational units |
| all_organizational_units | Combined map of all organizational units |
