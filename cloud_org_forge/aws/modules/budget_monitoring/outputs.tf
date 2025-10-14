output "budget_arns" {
  description = "ARNs of created budgets"
  value       = { for k, v in aws_budgets_budget.account_budgets : k => v.arn }
}

output "budget_names" {
  description = "Names of created budgets"
  value       = { for k, v in aws_budgets_budget.account_budgets : k => v.name }
}
