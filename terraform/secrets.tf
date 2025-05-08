# AWS Secrets Manager configuration
data "aws_secretsmanager_secret" "aws_credentials" {
  count = var.secret_arn != "" ? 1 : 0
  arn   = var.secret_arn
}

data "aws_secretsmanager_secret_version" "current" {
  count     = var.secret_arn != "" ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.aws_credentials[0].id
}

locals {
  use_secrets_manager = var.secret_arn != ""
  aws_credentials     = local.use_secrets_manager ? jsondecode(data.aws_secretsmanager_secret_version.current[0].secret_string) : {}
  
  # Use either the values from Secrets Manager or the provided variables
  access_key = local.use_secrets_manager ? lookup(local.aws_credentials, "access_key", "") : var.aws_access_key
  secret_key = local.use_secrets_manager ? lookup(local.aws_credentials, "secret_key", "") : var.aws_secret_key
}