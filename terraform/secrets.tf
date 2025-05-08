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
  # AWS credentials handling
  use_aws_secrets_manager = var.aws_secret_arn != ""
  aws_credentials_string  = local.use_aws_secrets_manager ? data.aws_secretsmanager_secret_version.aws_current[0].secret_string : "{}"
  aws_credentials         = can(jsondecode(local.aws_credentials_string)) ? jsondecode(local.aws_credentials_string) : {}
  
  access_key = local.use_aws_secrets_manager ? lookup(local.aws_credentials, "access_key", lookup(local.aws_credentials, "AccessKey", lookup(local.aws_credentials, "accessKey", ""))) : var.aws_access_key
  secret_key = local.use_aws_secrets_manager ? lookup(local.aws_credentials, "secret_key", lookup(local.aws_credentials, "SecretKey", lookup(local.aws_credentials, "secretKey", ""))) : var.aws_secret_key
  
  # GitHub token handling
  use_github_secrets_manager = var.github_secret_arn != ""
  github_secret_string       = local.use_github_secrets_manager ? data.aws_secretsmanager_secret_version.github_current[0].secret_string : "{}"
  
  # Try to parse as JSON, if it fails, treat the entire string as the token
  github_secret_is_json = can(jsondecode(local.github_secret_string))
  github_secret         = local.github_secret_is_json ? jsondecode(local.github_secret_string) : {}
  
  # Look for token in various possible JSON keys, or use the entire string if not JSON
  github_token = local.use_github_secrets_manager ? (
    local.github_secret_is_json ? 
      lookup(local.github_secret, "token", 
        lookup(local.github_secret, "Token", 
          lookup(local.github_secret, "github_token", 
            lookup(local.github_secret, "githubToken", "")
          )
        )
      ) : local.github_secret_string
  ) : var.github_token
}