variable "budgets" {
  description = "Map of budget configurations"
  type = map(object({
    account_id = string
    amount     = number
    thresholds = list(number)
  }))
}

variable "notification_email" {
  description = "Email address for budget notifications"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
