# AWS Bootstrap

Creates the foundational AWS resources needed for Terraform remote state management.

## Resources Created
- S3 bucket for state storage
- DynamoDB table for state locking

## Usage
```bash
terraform init -backend-config=backend.hcl
terraform apply
```

## Important
- Run this ONCE before any other AWS environments
- Keep the local state file safe
- Don't delete these resources while other projects depend on them
