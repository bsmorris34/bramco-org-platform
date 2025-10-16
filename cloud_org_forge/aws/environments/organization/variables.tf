variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "account_ids" {
  description = "AWS Account IDs for each environment"
  type = object({
    management = string
    dev        = string
    staging    = string
    prod       = string
  })
}

variable "notification_email" {
  description = "Email address for budget and other notifications"
  type        = string
}

variable "budget_amounts" {
  description = "Monthly budget amounts for each account"
  type = object({
    management = number
    dev        = number
    staging    = number
    prod       = number
  })
  default = {
    management = 50
    dev        = 25
    staging    = 30
    prod       = 100
  }
}

variable "budget_thresholds" {
  description = "Budget alert thresholds as percentages"
  type        = list(number)
  default     = [50, 80, 100]
}

variable "github_repository" {
  description = "GitHub repository for OIDC integration (format: username/repo-name)"
  type        = string
}
