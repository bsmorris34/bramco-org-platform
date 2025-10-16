"""Security tests for Terraform infrastructure using Checkov."""

import pytest
import subprocess  # nosec B404
import json
import os


@pytest.mark.security
def test_checkov_security_scan():
    """Run Checkov security scan on Terraform code."""
    # Path to your Terraform code
    terraform_path = "cloud_org_forge/aws/environments/organization"

    # Run Checkov scan
    result = subprocess.run(  # nosec B603 B607
        [
            "checkov",
            "-d",
            terraform_path,
            "--framework",
            "terraform",
            "--output",
            "json",
            "--quiet",
        ],
        capture_output=True,
        text=True,
    )

    # Parse results
    if result.stdout:
        scan_results = json.loads(result.stdout)
        failed_checks = scan_results.get("results", {}).get("failed_checks", [])

        # Assert no critical security issues
        critical_failures = [
            check for check in failed_checks if check.get("severity") == "CRITICAL"
        ]

        assert (
            len(critical_failures) == 0
        ), f"Critical security issues found: {critical_failures}"

    # Checkov should run successfully
    assert result.returncode in [0, 1], f"Checkov failed to run: {result.stderr}"


@pytest.mark.security
def test_terraform_validate():
    """Run terraform validate to check syntax."""
    terraform_path = "cloud_org_forge/aws/environments/organization"

    # Change to terraform directory
    original_dir = os.getcwd()
    os.chdir(terraform_path)

    try:
        # Run terraform validate
        result = subprocess.run(  # nosec B603 B607
            ["terraform", "validate"], capture_output=True, text=True
        )

        assert result.returncode == 0, f"Terraform validation failed: {result.stderr}"

    finally:
        # Always return to original directory
        os.chdir(original_dir)


@pytest.mark.security
def test_no_hardcoded_secrets():
    """Check for hardcoded secrets in Python code."""
    result = subprocess.run(  # nosec B603 B607
        ["bandit", "-r", "tests/", "-f", "json"], capture_output=True, text=True
    )

    if result.stdout:
        bandit_results = json.loads(result.stdout)
        high_severity_issues = [
            issue
            for issue in bandit_results.get("results", [])
            if issue.get("issue_severity") == "HIGH"
        ]

        assert (
            len(high_severity_issues) == 0
        ), f"High severity security issues found: {high_severity_issues}"


@pytest.mark.security
def test_tflint_code_quality():
    """Run TFLint to check Terraform code quality and best practices."""
    terraform_path = "cloud_org_forge/aws/environments/organization"

    # Change to terraform directory
    original_dir = os.getcwd()
    os.chdir(terraform_path)

    try:
        # Initialize TFLint (downloads plugins)
        # init_result = subprocess.run(
        #    ["tflint", "--init"], capture_output=True, text=True
        # )

        # Run TFLint
        result = subprocess.run(  # nosec B603 B607
            ["tflint", "--format=json"], capture_output=True, text=True
        )

        # Parse results if JSON output exists
        if result.stdout:
            try:
                tflint_results = json.loads(result.stdout)
                issues = tflint_results.get("issues", [])

                # Filter for high severity issues
                high_severity_issues = [
                    issue
                    for issue in issues
                    if issue.get("rule", {}).get("severity") == "error"
                ]

                assert (
                    len(high_severity_issues) == 0
                ), f"TFLint found high severity issues: {high_severity_issues}"

            except json.JSONDecodeError:
                # If no JSON output, check return code
                pass

        # TFLint should run successfully (0 = no issues, 2 = issues found but not critical)
        assert result.returncode in [0, 2], f"TFLint failed to run: {result.stderr}"

    finally:
        # Always return to original directory
        os.chdir(original_dir)
