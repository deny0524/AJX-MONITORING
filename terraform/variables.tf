variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for the monitoring server (Ubuntu recommended)"
  type        = string
  default     = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS in us-east-1
}

variable "instance_type" {
  description = "Instance type for the monitoring server"
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to deploy the monitoring server"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the monitoring server"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "repo_url" {
  description = "URL of the monitoring repository"
  type        = string
  default     = "https://github.com/your-org/AJX-MONITORING.git"
}

variable "github_token" {
  description = "GitHub Personal Access Token for private repository access"
  type        = string
  sensitive   = true
  default     = ""
}

variable "grafana_admin_user" {
  description = "Grafana admin username"
  type        = string
  default     = "admin"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "aws_access_key" {
  description = "AWS access key for EC2 discovery"
  type        = string
  sensitive   = true
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS secret key for EC2 discovery"
  type        = string
  sensitive   = true
  default     = ""
}

variable "aws_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret containing AWS credentials"
  type        = string
  default     = ""
}

variable "github_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret containing GitHub token"
  type        = string
  default     = ""
}