variable "permission_sets" {
  description = "Map of SSO permission sets to create"
  type = map(object({
    name             = string
    description      = string
    session_duration = optional(string, "PT8H")
    managed_policies = optional(list(string), [])
    inline_policies  = optional(map(string), {})
  }))
  default = {}
}

variable "account_assignments" {
  description = "Map of account assignments for permission sets"
  type = map(object({
    permission_set_key = string
    principal_id       = string
    principal_type     = string
    target_id          = string
    target_type        = string
  }))
  default = {}
}
