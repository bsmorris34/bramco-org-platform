output "organizational_units" {
  description = "Map of created organizational units"
  value = {
    for k, v in aws_organizations_organizational_unit.this : k => {
      id   = v.id
      arn  = v.arn
      name = v.name
    }
  }
}

output "nested_organizational_units" {
  description = "Map of created nested organizational units"
  value = {
    for k, v in aws_organizations_organizational_unit.nested : k => {
      id   = v.id
      arn  = v.arn
      name = v.name
    }
  }
}

output "all_organizational_units" {
  description = "Combined map of all organizational units (main + nested)"
  value = merge(
    {
      for k, v in aws_organizations_organizational_unit.this : k => {
        id   = v.id
        arn  = v.arn
        name = v.name
      }
    },
    {
      for k, v in aws_organizations_organizational_unit.nested : k => {
        id   = v.id
        arn  = v.arn
        name = v.name
      }
    }
  )
}

output "ou_ids" {
  description = "Map of organizational unit IDs"
  value = {
    for k, v in aws_organizations_organizational_unit.this : k => v.id
  }
}

output "nested_ou_ids" {
  description = "Map of nested organizational unit IDs"
  value = {
    for k, v in aws_organizations_organizational_unit.nested : k => v.id
  }
}
