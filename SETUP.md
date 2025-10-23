# Setup Instructions

## Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- GitHub repository with Actions enabled

## Initial Setup

### 1. Configure Variables
```bash
# Copy example configuration
cp cloud_org_forge/aws/environments/organization/terraform.tfvars.example \
   cloud_org_forge/aws/environments/organization/terraform.tfvars

# Edit with your actual values
vim cloud_org_forge/aws/environments/organization/terraform.tfvars
```

### 2. Update Backend Configuration
Edit `cloud_org_forge/aws/environments/organization/backend.hcl` with your S3 bucket:
```hcl
bucket = "your-terraform-state-bucket"
key    = "organization/terraform.tfstate"
region = "us-east-1"
```

### 3. Configure GitHub Secrets
Add these secrets to your GitHub repository:
- `AWS_ROLE_ARN`: Your OIDC role ARN (e.g., `arn:aws:iam::111111111111:role/GitHubActionsDeploymentRole`)
- `AWS_REGION`: `us-east-1`
- `MANAGEMENT_ACCOUNT_ID`: Your management account ID
- `DEV_ACCOUNT_ID`: Your dev account ID
- `STAGING_ACCOUNT_ID`: Your staging account ID
- `PROD_ACCOUNT_ID`: Your prod account ID
- `NOTIFICATION_EMAIL`: Your email for budget alerts
- `REPOSITORY_NAME`: Your repository in format `username/repo-name`

### 4. Initialize and Deploy
```bash
cd cloud_org_forge/aws/environments/organization
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

## Required Values

### Account IDs
Replace placeholder account IDs in `terraform.tfvars`:
- `management`: Your AWS management account ID
- `dev`: Your development account ID
- `staging`: Your staging account ID
- `prod`: Your production account ID

### Email Configuration
Update `notification_email` with your email address for budget alerts.

### GitHub Repository
Update `github_repository` with your repository in format `username/repo-name`.
