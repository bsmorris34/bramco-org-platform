"""Unit tests for Terraform configuration validation."""

import pytest


@pytest.mark.unit
def test_terraform_vars_structure(terraform_vars):
    """Test that terraform variables have correct structure."""
    # Test required keys exist
    assert "aws_region" in terraform_vars
    assert "account_ids" in terraform_vars
    assert "notification_email" in terraform_vars

    # Test account structure
    account_ids = terraform_vars["account_ids"]
    required_accounts = ["management", "dev", "staging", "prod"]

    for account in required_accounts:
        assert account in account_ids
        assert len(account_ids[account]) == 12  # AWS account IDs are 12 digits


@pytest.mark.unit
def test_aws_region_validation(terraform_vars):
    """Test that AWS region is valid."""
    assert terraform_vars["aws_region"] == "us-east-1"


@pytest.mark.unit
def test_email_format(terraform_vars):
    """Test that notification email has valid format."""
    email = terraform_vars["notification_email"]
    assert "@" in email
    assert "." in email


@pytest.mark.unit
def test_account_id_format(terraform_vars):
    """Test AWS account IDs are valid format."""
    account_ids = terraform_vars["account_ids"]

    for account_name, account_id in account_ids.items():
        # Must be exactly 12 digits
        assert len(account_id) == 12, f"{account_name} account ID must be 12 digits"
        # Must be all numbers
        assert account_id.isdigit(), f"{account_name} account ID must be numeric"
        # Must not start with 0
        assert not account_id.startswith(
            "0"
        ), f"{account_name} account ID cannot start with 0"


@pytest.mark.unit
def test_budget_business_rules(terraform_vars):
    """Test budget allocation follows business rules."""
    budgets = terraform_vars["budget_amounts"]

    # Production should have highest budget
    assert (
        budgets["prod"] >= budgets["staging"]
    ), "Production budget should be >= staging"
    assert budgets["staging"] >= budgets["dev"], "Staging budget should be >= dev"

    # All budgets should be positive
    for account, amount in budgets.items():
        assert amount > 0, f"{account} budget must be positive"

    # Management account should have reasonable budget
    assert budgets["management"] >= 25, "Management account needs minimum budget"


@pytest.mark.unit
def test_budget_thresholds(terraform_vars):
    """Test budget thresholds are valid."""
    thresholds = terraform_vars["budget_thresholds"]

    # Should have 3 thresholds
    assert len(thresholds) == 3, "Should have exactly 3 budget thresholds"

    # Should be in ascending order
    assert thresholds == sorted(thresholds), "Thresholds should be in ascending order"

    # Should be reasonable percentages
    for threshold in thresholds:
        assert 0 < threshold <= 100, f"Threshold {threshold} should be between 1-100"

    # Should include common alert levels
    assert 50 in thresholds, "Should include 50% threshold"
    assert 100 in thresholds, "Should include 100% threshold"


@pytest.mark.unit
def test_github_repository_format(terraform_vars):
    """Test GitHub repository format is valid."""
    repo = terraform_vars["github_repository"]

    # Should be in "owner/repo" format
    assert "/" in repo, "Repository should be in 'owner/repo' format"

    parts = repo.split("/")
    assert len(parts) == 2, "Repository should have exactly one slash"

    owner, repo_name = parts
    assert len(owner) > 0, "Repository owner cannot be empty"
    assert len(repo_name) > 0, "Repository name cannot be empty"

    # Should not contain invalid characters
    invalid_chars = [" ", "@", "#", "$", "%"]
    for char in invalid_chars:
        assert char not in repo, f"Repository should not contain '{char}'"


@pytest.mark.unit
def test_required_accounts_present(terraform_vars):
    """Test all required AWS accounts are configured."""
    account_ids = terraform_vars["account_ids"]
    budget_amounts = terraform_vars["budget_amounts"]

    required_accounts = ["management", "dev", "staging", "prod"]

    # All required accounts should have IDs
    for account in required_accounts:
        assert account in account_ids, f"Missing account ID for {account}"
        assert account in budget_amounts, f"Missing budget for {account}"

    # Account IDs should be unique
    ids = list(account_ids.values())
    assert len(ids) == len(set(ids)), "Account IDs must be unique"


@pytest.mark.unit
def test_aws_region_restrictions(terraform_vars):
    """Test AWS region follows organizational restrictions."""
    region = terraform_vars["aws_region"]

    # Should be us-east-1 per SCP restrictions
    assert region == "us-east-1", "Region must be us-east-1 per SCP policy"

    # Should be valid AWS region format
    assert region.startswith("us-"), "Region should be in US"
    assert "-" in region, "Region should have proper format (us-east-1)"
