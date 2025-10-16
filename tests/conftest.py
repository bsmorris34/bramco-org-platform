"""Shared pytest fixtures for infrastructure testing."""

import os
import pytest
import boto3
from moto import mock_aws


@pytest.fixture
def aws_credentials():
    """Mock AWS credentials for testing."""
    os.environ["AWS_ACCESS_KEY_ID"] = "testing"
    os.environ["AWS_SECRET_ACCESS_KEY"] = "testing"
    os.environ["AWS_DEFAULT_REGION"] = "us-east-1"


@pytest.fixture
def mock_aws_services(aws_credentials):
    """Mock all AWS services used in the infrastructure."""
    with mock_aws():
        yield


@pytest.fixture
def terraform_vars():
    """Sample terraform variables for testing."""
    return {
        "aws_region": "us-east-1",
        "account_ids": {
            "management": "123456789012",
            "dev": "123456789013", 
            "staging": "123456789014",
            "prod": "123456789015"
        },
        "notification_email": "test@example.com",
        "budget_amounts": {
            "management": 50,
            "dev": 25,
            "staging": 30,
            "prod": 100
        },
        "budget_thresholds": [50, 80, 100],
        "github_repository": "testuser/test-repo"
    }
