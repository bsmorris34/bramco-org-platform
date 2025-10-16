variable "policies" {
  description = "Map of service control policies to create"
  type = map(object({
    name            = string
    description     = string
    policy_document = string
  }))
  default = {}
}

variable "policy_attachments" {
  description = "Map of policy attachments to organizational units"
  type = map(object({
    policy_key = string # Key from policies map
    target_id  = string # OU ID to attach policy to
  }))
  default = {}
}
