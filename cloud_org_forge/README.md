# Cloud Organization Forge - Multi-Cloud Organization Management

This repository manages organization-level infrastructure and configuration across AWS, Azure, and GCP using Terraform and Ansible.

## Structure

```
cloud_org_forge/
├── aws/
│   ├── environments/
│   │   ├── bootstrap/      # Bootstrap S3 backend resources
│   │   └── organization/   # AWS Organizations management
│   ├── ansible/           # AWS-specific configuration
│   │   ├── playbooks/     # AWS configuration playbooks
│   │   ├── roles/         # AWS-specific roles
│   │   └── inventory/     # AWS inventory files
│   └── modules/           # AWS-specific modules
├── azure/
│   ├── environments/
│   │   └── organization/   # Azure tenant/management groups
│   ├── ansible/           # Azure-specific configuration
│   └── modules/           # Azure-specific modules
├── gcp/
│   ├── environments/
│   │   └── organization/   # GCP organization/folders
│   ├── ansible/           # GCP-specific configuration
│   └── modules/           # GCP-specific modules
└── shared/
    ├── modules/           # Cross-cloud reusable modules
    ├── policies/          # Shared policies and conventions
    └── ansible/           # Cross-cloud Ansible playbooks
        ├── playbooks/     # Multi-cloud orchestration
        └── roles/         # Reusable roles
```

## Workflow: Terraform + Ansible

### 1. Infrastructure Provisioning (Terraform)
```bash
# Bootstrap backend
cd aws/environments/bootstrap
terraform init -backend-config=backend.hcl
terraform apply

# Create organization structure
cd ../organization
terraform init -backend-config=backend.hcl
terraform apply
```

### 2. Configuration Management (Ansible)
```bash
# Configure organization policies
cd ../../ansible
ansible-playbook -i inventory/hosts.yml playbooks/configure-accounts.yml

# Multi-cloud configuration
cd ../../../shared/ansible
ansible-playbook playbooks/configure-organization.yml -e cloud_provider=aws
```

## Use Cases for Ansible in Organization Management

- **Policy Configuration**: Apply consistent security policies across accounts
- **Account Setup**: Configure new accounts with standard settings
- **Compliance Checks**: Validate organization compliance
- **Multi-Cloud Orchestration**: Coordinate configurations across clouds
- **Secrets Management**: Distribute secrets and certificates

## State Files (Centralized in AWS S3)

- Bootstrap: `bootstrap/terraform.tfstate`
- AWS Org: `aws/organization/terraform.tfstate`
- Azure Org: `azure/organization/terraform.tfstate`
- GCP Org: `gcp/organization/terraform.tfstate`
