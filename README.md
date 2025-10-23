# Bramco Organization Platform

AWS multi-account organization infrastructure managed with Terraform and automated via GitHub Actions.

## 🏗️ Architecture

### Account Structure
- **Management Account**: Organization root, SSO, billing
- **Dev Account**: Development workloads
- **Staging Account**: Pre-production testing
- **Production Account**: Production workloads

### Organizational Units
```
Root
├── Security OU
├── Workloads OU
│   ├── Dev OU
│   ├── Staging OU
│   └── Prod OU
└── Sandbox OU
```

## 🔐 Security & Access

### Service Control Policies (SCPs)
- **Root Access Denial**: Prevents root user access across all accounts
- **MFA Enforcement**: Requires multi-factor authentication
- **Region Restriction**: Limits operations to us-east-1 only
- **Account Creation Prevention**: Blocks unauthorized account creation

### SSO Permission Sets
- **Developer**: Full dev account access
- **DevOps Staging/Production**: Environment-specific deployment rights
- **Security Auditor**: Read-only security monitoring across all accounts
- **Platform Engineer**: Organization management in management account
- **Emergency Admin**: Break-glass admin access (2-hour sessions)

## 💰 Cost Management

Monthly budgets with email alerts at 50%, 80%, 100%:
- Management: $50
- Dev: $25
- Staging: $30
- Production: $100

## 🚀 CI/CD Automation

### GitHub Actions Workflows

#### Pull Request Workflow (`terraform-plan.yml`)
- **Trigger**: PRs to main branch
- **Actions**:
  - Authenticate via OIDC
  - Run `terraform plan`
  - Show plan in PR comments

#### Deploy Workflow (`terraform-deploy.yml`)
- **Trigger**: Push to main branch
- **Actions**:
  - Authenticate via OIDC
  - Run `terraform plan`
  - Run `terraform apply`

### OIDC Configuration
- **Provider**: GitHub Actions OIDC
- **Role**: `GitHubActionsDeploymentRole`
- **Repository**: [Your GitHub Repository]
- **Permissions**: Full organization and infrastructure management

## 🛠️ Development Workflow

### Making Changes
1. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-change
   ```

2. **Make Infrastructure Changes**
   - Edit Terraform files in `cloud_org_forge/aws/`
   - Copy `terraform.tfvars.example` to `terraform.tfvars` and update with your values

3. **Create Pull Request**
   - Push branch to GitHub
   - Create PR to main
   - Review terraform plan in PR comments

4. **Deploy**
   - Merge PR to main
   - Automatic deployment via GitHub Actions

### Local Development
```bash
# Initialize Terraform
cd cloud_org_forge/aws/environments/organization
terraform init -backend-config=backend.hcl

# Plan changes
terraform plan

# Apply changes (use GitHub Actions for production)
terraform apply
```

## 📁 Project Structure

```
cloud_org_forge/
└── aws/
    ├── environments/
    │   └── organization/
    │       ├── main.tf              # Main configuration
    │       ├── variables.tf         # Variable definitions
    │       ├── terraform.tfvars.example # Example variable values
    │       ├── terraform.tfvars     # Your variable values (gitignored)
    │       ├── backend.tf           # S3 backend config
    │       └── backend.hcl          # Backend parameters
    └── modules/
        ├── organizational_units/    # OU management
        ├── service_control_policies/ # SCP management
        ├── sso_permission_sets/     # SSO configuration
        ├── budget_monitoring/       # Cost management
        └── github_oidc/            # OIDC integration
```

## 🔧 Configuration

### Required GitHub Secrets
- `AWS_ROLE_ARN`: `arn:aws:iam::<MANAGEMENT_ACCOUNT_ID>:role/GitHubActionsDeploymentRole`
- `AWS_REGION`: `us-east-1`

### Backend Configuration
- **S3 Bucket**: `bramco1-terraform-state-3725`
- **DynamoDB Table**: `cloud-org-forge-state-lock`
- **Region**: `us-east-1`

## 🚨 Emergency Procedures

### Break-Glass Access
1. Use Emergency Admin permission set in AWS SSO
2. Limited to 2-hour sessions
3. Full admin access across all accounts

### Workflow Failures
1. Check GitHub Actions logs
2. Verify AWS credentials and permissions
3. Ensure terraform.tfvars values are correct
4. Manual recovery via local Terraform if needed

## 📋 Maintenance

### Regular Tasks
- Review budget alerts monthly
- Audit SSO access quarterly
- Update Terraform providers annually
- Review SCP effectiveness semi-annually

### Monitoring
- AWS Cost and Usage Reports
- CloudTrail logs for security events
- SSO access logs for compliance

## 🤝 Contributing

1. Follow the development workflow above
2. Ensure all changes are tested via PR workflow
3. Document significant architectural changes
4. Update this README for new features or processes
