# Get current AWS Organization details
data "aws_organizations_organization" "current" {}

# Generate standardized tags for all resources
module "common_tags" {
  source = "../../../shared/modules/common-tags"
  
  environment   = "organization"
  project_name  = "bramco1"
  owner         = "platform-team"
}

# Create organizational unit structure for account management
module "organizational_units" {
  source = "../../modules/organizational_units"

  # Top-level OUs directly under root
  organizational_units = {
    security = {
      name      = "Security"
      parent_id = data.aws_organizations_organization.current.roots[0].id
      tags = {
        Purpose = "Security and compliance workloads"
      }
    }
    
    workloads = {
      name      = "Workloads"
      parent_id = data.aws_organizations_organization.current.roots[0].id
      tags = {
        Purpose = "Application and service workloads"
      }
    }
    
    sandbox = {
      name      = "Sandbox"
      parent_id = data.aws_organizations_organization.current.roots[0].id
      tags = {
        Purpose = "Development and experimentation"
      }
    }
  }

  # Environment-specific OUs nested under Workloads OU
  nested_organizational_units = {
    dev_workloads = {
      name          = "Development"
      parent_ou_key = "workloads"  # References workloads OU above
      tags = {
        Environment = "development"
      }
    }
    
    staging_workloads = {
      name          = "Staging"
      parent_ou_key = "workloads"  # References workloads OU above
      tags = {
        Environment = "staging"
      }
    }
    
    prod_workloads = {
      name          = "Production"
      parent_ou_key = "workloads"  # References workloads OU above
      tags = {
        Environment = "production"
      }
    }
  }

  common_tags = module.common_tags.common_tags
}

# Assign existing AWS accounts to their respective organizational units
module "account_assignments" {
  source = "../../modules/account_assignments"

  account_assignments = {
    dev_account = {
      account_id = var.account_ids.dev
      ou_id      = module.organizational_units.nested_ou_ids["dev_workloads"]
    }

    staging_account = {
      account_id = var.account_ids.staging
      ou_id      = module.organizational_units.nested_ou_ids["staging_workloads"]
    }

    prod_account = {
      account_id = var.account_ids.prod
      ou_id      = module.organizational_units.nested_ou_ids["prod_workloads"]
    }
  }
}

# Create and attach Service Control Policies for security and compliance
module "service_control_policies" {
  source = "../../modules/service_control_policies"

  # Define security policies
  policies = {
    deny_root_access = {
      name            = "DenyRootAccess"
      description     = "Prevent root user access in workload accounts"
      policy_document = file("${path.module}/../../modules/service_control_policies/deny_root_access.json")
    }
    
    deny_account_creation = {
      name            = "DenyAccountCreation"
      description     = "Prevent accidental account creation"
      policy_document = file("${path.module}/../../modules/service_control_policies/deny_account_creation.json")
    }
    
    require_mfa = {
      name            = "RequireMFA"
      description     = "Require MFA for sensitive actions"
      policy_document = file("${path.module}/../../modules/service_control_policies/require_mfa.json")
    }

    restrict_regions = {
      name            = "RestrictRegions"
      description     = "Restrict operations to us-east-1 only"
      policy_document = file("${path.module}/../../modules/service_control_policies/restrict_regions.json")
    }
  }

  # Attach policies to appropriate OUs and root
  policy_attachments = {
    # Prevent account creation at organization root level
    root_deny_account_creation = {
      policy_key = "deny_account_creation"
      target_id  = data.aws_organizations_organization.current.roots[0].id
    }
    
    # Prevent root user access in all workload accounts
    workloads_deny_root = {
      policy_key = "deny_root_access"
      target_id  = module.organizational_units.ou_ids["workloads"]
    }
    
    # Require MFA for sensitive operations in workload accounts
    workloads_require_mfa = {
      policy_key = "require_mfa"
      target_id  = module.organizational_units.ou_ids["workloads"]
    }

    # Restrict all operations to us-east-1 region
    root_restrict_regions = {
      policy_key = "restrict_regions"
      target_id  = data.aws_organizations_organization.current.roots[0].id
    }
  }
}

# Get SSO instances for user lookup
data "aws_ssoadmin_instances" "main" {}

# Get Brandon user from Identity Center for permission set assignments
data "aws_identitystore_user" "brandon" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = "Brandon"
    }
  }
}

# Create SSO Permission Sets and Account Assignments for role-based access
module "sso_permission_sets" {
  source = "../../modules/sso_permission_sets"

  # Define permission sets for different roles and environments
  permission_sets = {
    # DEVELOPER ROLE - Dev environment only, full development access
    brandon_developer = {
      name        = "BrandonDeveloper"
      description = "Developer - Building and experimenting in dev environment only"
      managed_policies = [
        "arn:aws:iam::aws:policy/PowerUserAccess"  # Full access except IAM
      ]
      session_duration = "PT8H"  # 8 hour sessions
      inline_policies = {}
    }
    
    # DEVOPS STAGING ROLE - Staging deployment and testing
    brandon_devops_staging = {
      name        = "BrandonDevOpsStaging"
      description = "DevOps Engineer - Staging deployment and testing"
      managed_policies = [
        "arn:aws:iam::aws:policy/AWSLambda_FullAccess",
        "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator",
        "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
        "arn:aws:iam::aws:policy/CloudWatchFullAccess"
      ]
      session_duration = "PT8H"  # 8 hour sessions
      inline_policies = {}
    }
    
    # DEVOPS PRODUCTION ROLE - Restricted production deployment
    brandon_devops_production = {
      name        = "BrandonDevOpsProduction"
      description = "DevOps Engineer - Production deployment with restrictions"
      managed_policies = [
        "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
      ]
      session_duration = "PT4H"  # Shorter 4 hour sessions for production
      inline_policies = {
        # Custom policy for limited production deployment actions
        production_deploy = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "lambda:UpdateFunctionCode",
                "lambda:UpdateFunctionConfiguration",
                "lambda:PublishVersion",
                "lambda:UpdateAlias",
                "lambda:GetFunction",
                "lambda:ListFunctions"
              ]
              Resource = "*"
            },
            {
              Effect = "Allow"
              Action = [
                "apigateway:GET",
                "apigateway:PUT",
                "apigateway:POST"
              ]
              Resource = "*"
            },
            {
              Effect = "Allow"
              Action = [
                "dynamodb:DescribeTable",
                "dynamodb:UpdateTable"
              ]
              Resource = "*"
            }
          ]
        })
      }
    }
    
    # SECURITY AUDITOR ROLE - Cross-account security monitoring
    brandon_security_auditor = {
      name        = "BrandonSecurityAuditor"
      description = "Security Auditor - Cross-account compliance and security monitoring"
      managed_policies = [
        "arn:aws:iam::aws:policy/SecurityAudit",    # Security-focused read access
        "arn:aws:iam::aws:policy/ReadOnlyAccess"    # General read-only access
      ]
      session_duration = "PT8H"  # 8 hour sessions
      inline_policies = {}
    }
    
    # PLATFORM ENGINEER ROLE - Management account infrastructure only
    brandon_platform_engineer = {
      name        = "BrandonPlatformEngineer"
      description = "Platform Engineer - Management account infrastructure and organization management"
      managed_policies = [
        "arn:aws:iam::aws:policy/AWSOrganizationsFullAccess",
        "arn:aws:iam::aws:policy/AWSSSOMasterAccountAdministrator",
        "arn:aws:iam::aws:policy/job-function/Billing",
        "arn:aws:iam::aws:policy/AWSBudgetsActionsWithAWSResourceControlAccess"
      ]
      session_duration = "PT4H"  # Shorter sessions for high-privilege role
      inline_policies = {
        # Custom policy for platform management with region restriction
        platform_management = jsonencode({
          Version = "2012-10-17"
          Statement = [
            {
              Effect = "Allow"
              Action = [
                "iam:*",
                "s3:*",
                "dynamodb:*",
                "cloudformation:*",
                "lambda:*"
              ]
              Resource = "*"
              Condition = {
                StringEquals = {
                  "aws:RequestedRegion" = "us-east-1"  # Restrict to us-east-1 only
                }
              }
            }
          ]
        })
      }
    }
    
    # READ-ONLY MONITOR - All environments monitoring and troubleshooting
    brandon_monitor = {
      name        = "BrandonMonitor"
      description = "Monitor - Read-only access for troubleshooting and monitoring"
      managed_policies = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess",
        "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
      ]
      session_duration = "PT8H"  # 8 hour sessions
      inline_policies = {}
    }
    
    # EMERGENCY ADMIN - Break-glass admin access for all accounts
    brandon_emergency_admin = {
      name        = "BrandonEmergencyAdmin"
      description = "Emergency break-glass admin access for critical issues and account setup"
      managed_policies = [
        "arn:aws:iam::aws:policy/AdministratorAccess"
      ]
      session_duration = "PT2H"  # Short 2 hour sessions for security
      inline_policies = {}
    }
  }

  # Assign permission sets to Brandon across different accounts based on role
  account_assignments = {
    # DEVELOPER: Dev Account Only - Full development access, no staging/prod
    brandon_as_developer = {
      permission_set_key = "brandon_developer"
      principal_id       = data.aws_identitystore_user.brandon.user_id
      principal_type     = "USER"
      target_id          = var.account_ids.dev
      target_type        = "AWS_ACCOUNT"
    }
    
    # DEVOPS STAGING: Staging Account Only - Testing and deployment
    brandon_as_devops_staging = {
      permission_set_key = "brandon_devops_staging"
      principal_id       = data.aws_identitystore_user.brandon.user_id
      principal_type     = "USER"
      target_id          = var.account_ids.staging
      target_type        = "AWS_ACCOUNT"
    }
    
    # DEVOPS PRODUCTION: Production Account - Limited deployment capabilities
    brandon_as_devops_production = {
      permission_set_key = "brandon_devops_production"
      principal_id       = data.aws_identitystore_user.brandon.user_id
      principal_type     = "USER"
      target_id          = var.account_ids.prod
      target_type        = "AWS_ACCOUNT"
    }
    
    # SECURITY AUDITOR: Cross-account security monitoring and compliance
    brandon_as_security_management = {
      permission_set_key = "brandon_security_auditor"
      principal_id       = data.aws_identitystore_user.brandon.user_id
      principal_type     = "USER"
      target_id          = var.account_ids.management
      target_type        = "AWS_ACCOUNT"
    }
    
    brandon_as_security_dev = {
      permission_set_key = "brandon_security_auditor"
      principal_id       = data.aws_identitystore_user.brandon.user_id
      principal_type     = "USER"
      target_id          = var.account_ids.dev
      target_type        = "AWS_ACCOUNT"
    }
    
    brandon_as_security_staging = {
      permission_set_key = "brandon_security_auditor"
      principal_id       = data.aws_identitystore_user.brandon.user_id
      principal_type     = "USER"
      target_id          = var.account_ids.staging
      target_type        = "AWS_ACCOUNT"
    }
    
    brandon_as_security_prod = {
      permission_set_key = "brandon_security_auditor"
      principal_id       = data.aws_identitystore_user.brandon.user_id
      principal_type     = "USER"
      target_id          = var.account_ids.prod
      target_type        = "AWS_ACCOUNT"
    }
    
    # PLATFORM ENGINEER: Management Account Only - Organization and infrastructure management
    brandon_as_platform_engineer = {
      permission_set_key = "brandon_platform_engineer"
      principal_id       = data.aws_identitystore_user.brandon.user_id
      principal_type     = "USER"
      target_id          = var.account_ids.management
      target_type        = "AWS_ACCOUNT"
    }
    
    # MONITOR: Read-only access across all accounts for troubleshooting
    brandon_as_monitor_dev = {
      permission_set_key = "brandon_monitor"
      principal_id       = data.aws_identitystore_user.brandon.user_id
      principal_type     = "USER"
      target_id          = var.account_ids.dev
      target_type        = "AWS_ACCOUNT"
    }
    
    brandon_as_monitor_staging = {
      permission_set_key = "brandon_monitor"
      principal_id       = data.aws_identitystore_user.brandon.user_id
      principal_type     = "USER"
      target_id          = var.account_ids.staging
      target_type        = "AWS_ACCOUNT"
    }
    
    brandon_as_monitor_prod = {
      permission_set_key = "brandon_monitor"
      principal_id       = data.aws_identitystore_user.brandon.user_id
      principal_type     = "USER"
      target_id          = var.account_ids.prod
      target_type        = "AWS_ACCOUNT"
    }
    
    # EMERGENCY ADMIN: Break-glass access across all accounts
    brandon_as_emergency_admin_management = {
      permission_set_key = "brandon_emergency_admin"
      principal_id       = data.aws_identitystore_user.brandon.user_id
      principal_type     = "USER"
      target_id          = var.account_ids.management
      target_type        = "AWS_ACCOUNT"
    }
    
    brandon_as_emergency_admin_dev = {
      permission_set_key = "brandon_emergency_admin"
      principal_id       = data.aws_identitystore_user.brandon.user_id
      principal_type     = "USER"
      target_id          = var.account_ids.dev
      target_type        = "AWS_ACCOUNT"
    }
    
    brandon_as_emergency_admin_staging = {
      permission_set_key = "brandon_emergency_admin"
      principal_id       = data.aws_identitystore_user.brandon.user_id
      principal_type     = "USER"
      target_id          = var.account_ids.staging
      target_type        = "AWS_ACCOUNT"
    }
    
    brandon_as_emergency_admin_prod = {
      permission_set_key = "brandon_emergency_admin"
      principal_id       = data.aws_identitystore_user.brandon.user_id
      principal_type     = "USER"
      target_id          = var.account_ids.prod
      target_type        = "AWS_ACCOUNT"
    }
  }
}

# Create monthly cost budgets with email notifications for all accounts
module "budget_monitoring" {
  source = "../../modules/budget_monitoring"
  
  # Define budget limits and alert thresholds for each account
  budgets = {
    management_budget = {
      account_id = var.account_ids.management
      amount     = var.budget_amounts.management
      thresholds = var.budget_thresholds
    }
    dev_budget = {
      account_id = var.account_ids.dev
      amount     = var.budget_amounts.dev
      thresholds = var.budget_thresholds
    }
    staging_budget = {
      account_id = var.account_ids.staging
      amount     = var.budget_amounts.staging
      thresholds = var.budget_thresholds
    }
    prod_budget = {
      account_id = var.account_ids.prod
      amount     = var.budget_amounts.prod
      thresholds = var.budget_thresholds
    }
  }
  
  notification_email = var.notification_email
  common_tags       = module.common_tags.common_tags
}

# Configure GitHub OIDC for automated deployments
module "github_oidc" {
  source = "../../modules/github_oidc"
  
  github_repository = var.github_repository
  github_branches   = ["main", "feature/*"]
  role_name        = "GitHubActionsDeploymentRole"
  
  # Permissions for Terraform deployments
  role_policies = [
    "arn:aws:iam::aws:policy/AWSOrganizationsFullAccess",
    "arn:aws:iam::aws:policy/AWSSSOMasterAccountAdministrator",
    "arn:aws:iam::aws:policy/job-function/Billing",
    "arn:aws:iam::aws:policy/AWSBudgetsActionsWithAWSResourceControlAccess"
  ]
  
  # Custom inline policy for additional Terraform permissions
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:*",
          "s3:*",
          "dynamodb:*",
          "cloudformation:*",
          "lambda:*",
          "states:*"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "us-east-1"
          }
        }
      }
    ]
  })
  
  common_tags = module.common_tags.common_tags
}
# Test comment for GitHub Actions - deploy test
