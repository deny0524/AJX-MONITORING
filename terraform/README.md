# Terraform Deployment for AJX Monitoring Stack

This directory contains Terraform configurations to deploy the AJX Monitoring Stack on AWS.

## Prerequisites

- Terraform installed (version 1.0.0 or later)
- AWS CLI configured with appropriate credentials
- SSH key pair created in AWS

## Configuration

1. Copy the example variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` to set your specific configuration:

```
aws_region = "us-east-1"  # Change to your preferred region
ami_id = "ami-0c7217cdde317cfec"  # Ubuntu 22.04 LTS in us-east-1
instance_type = "t3.medium"
key_name = "your-key-pair"  # Your SSH key pair name
subnet_id = "subnet-12345678"  # Your subnet ID
allowed_cidr_blocks = ["10.0.0.0/8", "192.168.0.0/16"]  # IP ranges allowed to access
repo_url = "https://github.com/your-org/AJX-MONITORING.git"  # Your repository URL
grafana_admin_user = "admin"
grafana_admin_password = "secure_password"  # Set a secure password
aws_access_key = "your_aws_access_key"  # For EC2 discovery
aws_secret_key = "your_aws_secret_key"  # For EC2 discovery
```

## Deployment

1. Initialize Terraform:

```bash
terraform init
```

2. Preview the changes:

```bash
terraform plan
```

3. Apply the configuration:

```bash
terraform apply
```

4. After successful deployment, Terraform will output:
   - Monitoring server public and private IP addresses
   - URLs for Grafana, Prometheus, and AlertManager

## Accessing the Monitoring Stack

- Grafana: http://<server-ip>:3000
- Prometheus: http://<server-ip>:9090
- AlertManager: http://<server-ip>:9093

## Destroying the Infrastructure

To tear down the infrastructure:

```bash
terraform destroy
```

## Security Considerations

- The default configuration exposes the monitoring services to the internet. For production use, restrict `allowed_cidr_blocks` to your organization's IP ranges.
- Consider using AWS Secrets Manager or Parameter Store for sensitive values.
- For production environments, use HTTPS with valid certificates.