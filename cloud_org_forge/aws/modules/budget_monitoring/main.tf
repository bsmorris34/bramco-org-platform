resource "aws_budgets_budget" "account_budgets" {
  for_each = var.budgets

  name              = "${each.key}-monthly-budget"
  budget_type       = "COST"
  limit_amount      = tostring(each.value.amount)
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2025-01-01_00:00"

  cost_filter {
    name   = "LinkedAccount"
    values = [each.value.account_id]
  }

  dynamic "notification" {
    for_each = each.value.thresholds
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = [var.notification_email]
    }
  }

  dynamic "notification" {
    for_each = each.value.thresholds
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type             = "PERCENTAGE"
      notification_type          = "FORECASTED"
      subscriber_email_addresses = [var.notification_email]
    }
  }

  tags = merge(var.common_tags, {
    Name = "${each.key}-monthly-budget"
  })
}
