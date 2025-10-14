variable "organizational_units" {
  description = "Map of organizational units to create"
  type = map(object({
    name      = string
    parent_id = string
    tags      = optional(map(string), {})
  }))
  default = {}
}

variable "nested_organizational_units" {
  description = "Map of nested organizational units to create under the main OUs"
  type = map(object({
    name          = string
    parent_ou_key = string # Key from organizational_units map
    tags          = optional(map(string), {})
  }))
  default = {}
}

variable "common_tags" {
  description = "Common tags to apply to all organizational units"
  type        = map(string)
  default     = {}
}