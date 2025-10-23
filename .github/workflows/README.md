# GitHub Actions Workflows

This directory contains the CI/CD workflows for automated Terraform deployments.

## Workflows

### `terraform-plan.yml`
**Purpose**: Validate and preview infrastructure changes on pull requests

**Triggers**:
- Pull requests to `main` branch
- Changes to `cloud_org_forge/aws/**` paths

**Steps**:
1. Checkout repository code
2. Configure AWS credentials via OIDC
3. Setup Terraform
4. Initialize Terraform with S3 backend
5. Create `terraform.tfvars` at runtime
6. Run `terraform plan` and display output

**Permissions**:
- `id-token: write` - For OIDC authentication
- `contents: read` - To read repository files

### `terraform-deploy.yml`
**Purpose**: Deploy infrastructure changes to AWS

**Triggers**:
- Push to `main` branch
- Changes to `cloud_org_forge/aws/**` paths

**Steps**:
1. Checkout repository code
2. Configure AWS credentials via OIDC
3. Setup Terraform
4. Initialize Terraform with S3 backend
5. Create `terraform.tfvars` at runtime
6. Run `terraform plan` for verification
7. Run `terraform apply` with auto-approval

**Permissions**:
- `id-token: write` - For OIDC authentication
- `contents: read` - To read repository files

## Security

### OIDC Authentication
Both workflows use OpenID Connect (OIDC) to authenticate with AWS without storing long-lived credentials.

**Configuration**:
- **Provider**: GitHub Actions OIDC provider in AWS
- **Role**: `GitHubActionsDeploymentRole`
- **Trust Policy**: Allows `repo:your-username/your-repo-name:*`

### Runtime Configuration
The `terraform.tfvars` file is created at runtime to avoid storing sensitive account IDs in the repository. The file contains:

```hcl
aws_region = "us-east-1"
account_ids = {
  management = "111111111111"
  dev        = "222222222222"
  staging    = "333333333333"
  prod       = "444444444444"
}
notification_email = "your-email@example.com"
budget_amounts = {
  management = 50
  dev        = 25
  staging    = 30
  prod       = 100
}
budget_thresholds = [50, 80, 100]
github_repository = "your-username/your-repo-name"
```

## Troubleshooting

### Common Issues

**Workflow not triggering**:
- Ensure changes are in `cloud_org_forge/aws/**` paths
- Check branch name matches trigger conditions

**Authentication failures**:
- Verify GitHub secrets are set correctly
- Check OIDC trust policy allows the repository
- Ensure IAM role has necessary permissions

**Terraform errors**:
- Review Terraform logs in workflow output
- Verify backend configuration is correct
- Check for resource conflicts or permission issues

### Manual Recovery
If workflows fail and manual intervention is needed:

1. Use local AWS profile with appropriate permissions
2. Navigate to `cloud_org_forge/aws/environments/organization`
3. Run `terraform init -backend-config=backend.hcl`
4. Create `terraform.tfvars` with correct values
5. Run `terraform plan` and `terraform apply` as needed
