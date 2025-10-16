variable "account_assignments" {
  description = "Map of accounts to assign to organizational units"
  type = map(object({
    account_id = string
    ou_id      = string
  }))
  default = {}
}
