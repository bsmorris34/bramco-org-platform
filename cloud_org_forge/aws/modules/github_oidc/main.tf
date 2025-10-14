# Get GitHub OIDC thumbprint
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# Create OIDC Identity Provider
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  
  client_id_list = [
    "sts.amazonaws.com"
  ]
  
  thumbprint_list = [
    data.tls_certificate.github.certificates[0].sha1_fingerprint
  ]
  
  tags = merge(var.common_tags, {
    Name = "GitHub Actions OIDC Provider"
  })
}

# Create trust policy for GitHub Actions
data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect = "Allow"
    
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    
    actions = ["sts:AssumeRoleWithWebIdentity"]
    
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repository}:*"]
    }
  }
}

# Create IAM role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
  
  tags = merge(var.common_tags, {
    Name = var.role_name
  })
}

# Attach managed policies to the role
resource "aws_iam_role_policy_attachment" "github_actions" {
  count = length(var.role_policies)
  
  role       = aws_iam_role.github_actions.name
  policy_arn = var.role_policies[count.index]
}

# Create inline policy if provided
resource "aws_iam_role_policy" "github_actions_inline" {
  count = var.inline_policy != null ? 1 : 0
  
  name   = "${var.role_name}-inline-policy"
  role   = aws_iam_role.github_actions.id
  policy = var.inline_policy
}