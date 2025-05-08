# AWS Secrets Manager configuration for AWS credentials
data "aws_secretsmanager_secret" "aws_credentials" {
  count = var.aws_secret_arn != "" ? 1 : 0
  arn   = var.aws_secret_arn
}

data "aws_secretsmanager_secret_version" "aws_current" {
  count     = var.aws_secret_arn != "" ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.aws_credentials[0].id
}

# AWS Secrets Manager configuration for GitHub token
data "aws_secretsmanager_secret" "github_token" {
  count = var.github_secret_arn != "" ? 1 : 0
  arn   = var.github_secret_arn
}

data "aws_secretsmanager_secret_version" "github_current" {
  count     = var.github_secret_arn != "" ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.github_token[0].id
}

locals {
  use_aws_secrets_manager = var.aws_secret_arn != ""
  aws_credentials         = local.use_aws_secrets_manager ? jsondecode(data.aws_secretsmanager_secret_version.aws_current[0].secret_string) : {}
  
  # Use either the values from Secrets Manager or the provided variables
  access_key = local.use_aws_secrets_manager ? lookup(local.aws_credentials, "access_key", "") : var.aws_access_key
  secret_key = local.use_aws_secrets_manager ? lookup(local.aws_credentials, "secret_key", "") : var.aws_secret_key
  
  # GitHub token from Secrets Manager
  use_github_secrets_manager = var.github_secret_arn != ""
  github_secret              = local.use_github_secrets_manager ? jsondecode(data.aws_secretsmanager_secret_version.github_current[0].secret_string) : {}
  github_token               = local.use_github_secrets_manager ? lookup(local.github_secret, "token", "") : var.github_token
}