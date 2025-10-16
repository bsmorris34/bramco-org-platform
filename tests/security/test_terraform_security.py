"""Security tests for Terraform infrastructure using Checkov."""

import pytest
import subprocess
import json
import os


@pytest.mark.security
def test_checkov_security_scan():
    """Run Checkov security scan on Terraform code."""
    # Path to your Terraform code
    terraform_path = "cloud_org_forge/aws/environments/organization"
    
    # Run Checkov scan
    result = subprocess.run([
        "checkov", 
        "-d", terraform_path,
        "--framework", "terraform",
        "--output", "json",
        "--quiet"
    ], capture_output=True, text=True)
    
    # Parse results
    if result.stdout:
        scan_results = json.loads(result.stdout)
        failed_checks = scan_results.get("results", {}).get("failed_checks", [])
        
        # Assert no critical security issues
        critical_failures = [
            check for check in failed_checks 
            if check.get("severity") == "CRITICAL"
        ]
        
        assert len(critical_failures) == 0, f"Critical security issues found: {critical_failures}"
    
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
        result = subprocess.run(
            ["terraform", "validate"],
            capture_output=True,
            text=True
        )
        
        assert result.returncode == 0, f"Terraform validation failed: {result.stderr}"
        
    finally:
        # Always return to original directory
        os.chdir(original_dir)


@pytest.mark.security
def test_no_hardcoded_secrets():
    """Check for hardcoded secrets in Python code."""
    result = subprocess.run([
        "bandit", 
        "-r", "tests/",
        "-f", "json"
    ], capture_output=True, text=True)
    
    if result.stdout:
        bandit_results = json.loads(result.stdout)
        high_severity_issues = [
            issue for issue in bandit_results.get("results", [])
            if issue.get("issue_severity") == "HIGH"
        ]
        
        assert len(high_severity_issues) == 0, f"High severity security issues found: {high_severity_issues}"
