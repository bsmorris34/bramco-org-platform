resource "aws_organizations_organizational_unit" "this" {
  for_each  = var.organizational_units
  name      = each.value.name
  parent_id = each.value.parent_id

  tags = merge(
    var.common_tags,
    each.value.tags,
    {
      Name = each.value.name
    }
  )
}

# Create nested OUs if specified
resource "aws_organizations_organizational_unit" "nested" {
  for_each  = var.nested_organizational_units
  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.this[each.value.parent_ou_key].id

  tags = merge(
    var.common_tags,
    each.value.tags,
    {
      Name = each.value.name
    }
  )

  depends_on = [aws_organizations_organizational_unit.this]
}
