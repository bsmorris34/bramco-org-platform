# AWS Region (restricted by SCP to us-east-1 only)
aws_region = "us-east-1"

# AWS Account IDs for Bramco Organization
account_ids = {
  management = "396913723725"  # bramco management account
  dev        = "688567306703"  # bramco-dev account
  staging    = "400205986141"  # Bramco-Staging account
  prod       = "825765407025"  # bramco-prod account
}

# Email for notifications
notification_email = "bsmorris1+aws@gmail.com"

# Monthly budget amounts (optional - defaults defined in variables.tf)
budget_amounts = {
  management = 50
  dev        = 25
  staging    = 30
  prod       = 100
}

# Budget alert thresholds (optional - defaults defined in variables.tf)
budget_thresholds = [50, 80, 100]

# GitHub repository for automated deployments
github_repository = "bsmorris34/bramco-org-platform"