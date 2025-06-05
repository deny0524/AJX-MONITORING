# AJX Monitoring Stack

This repository contains a complete monitoring solution for EC2 instances created with AJX-ENV-DEVTOOL, using Prometheus and Grafana.

## Components

- **Prometheus**: Collects and stores metrics from EC2 instances
- **Grafana**: Visualizes metrics with pre-configured dashboards
- **AlertManager**: Handles alerts and notifications
- **Node Exporter**: Collects system metrics from EC2 instances

## Prerequisites

- Docker and Docker Compose installed on the monitoring server
- AWS IAM permissions for EC2 service discovery
- EC2 instances created with AJX-ENV-DEVTOOL and tagged appropriately

## Setup Instructions

### 1. Configure AWS Credentials for Prometheus

Prometheus needs AWS credentials to discover EC2 instances. Create an IAM user with the following policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
    }
  ]
}
```

Configure AWS credentials on the monitoring server:

```bash
aws configure
```

### 2. Deploy the Monitoring Stack

```bash
# Clone this repository
git clone <repository-url>
cd AJX-MONITORING

# Start the monitoring stack
docker-compose up -d
```

### 3. Install Node Exporter on EC2 Instances

Copy the `node-exporter-setup.sh` script to your EC2 instances and run it:

```bash
# On each EC2 instance
chmod +x node-exporter-setup.sh
sudo ./node-exporter-setup.sh
```

### 4. Configure Security Groups

Ensure your EC2 security groups allow:
- Inbound traffic on port 9100 from the Prometheus server (for Node Exporter)

### 5. Access the Dashboards

- Grafana: http://monitoring-server:3000 (default credentials: admin/ajx_secure_password)
- Prometheus: http://monitoring-server:9090
- AlertManager: http://monitoring-server:9093

## Customization

### Modifying Prometheus Configuration

Edit `prometheus/prometheus.yml` to adjust scrape intervals, add new targets, or modify EC2 discovery settings.

### Adding Custom Dashboards

Place JSON dashboard definitions in `grafana/dashboards/` and they will be automatically loaded.

### Configuring Alerts

Edit `prometheus/rules/alert_rules.yml` to modify existing alerts or add new ones.

### Configuring Alert Notifications

Edit `alertmanager/alertmanager.yml` to configure notification channels (email, Slack, etc.).

## Maintenance

### Updating the Stack

```bash
git pull
docker-compose down
docker-compose up -d
```

### Backing Up Grafana Dashboards

Grafana dashboards are stored in the `grafana_data` Docker volume. To back them up:

```bash
docker run --rm -v ajx-monitoring_grafana_data:/source -v $(pwd)/backup:/backup ubuntu tar -czvf /backup/grafana_data_backup.tar.gz -C /source .
```

## Troubleshooting

### Checking Prometheus Targets

1. Access the Prometheus UI at http://monitoring-server:9090
2. Go to Status > Targets to verify that all targets are up

### Checking Node Exporter

On the EC2 instance:

```bash
curl http://localhost:9100/metrics
```

### Checking Logs

```bash
docker-compose logs prometheus
docker-compose logs grafana
docker-compose logs alertmanager
```

## Cloudflare Monitoring Setup

This setup allows you to monitor your Cloudflare domain metrics in Grafana.

### Prerequisites

1. A Cloudflare account with at least one domain
2. API token with Analytics permissions

### Setup Instructions

1. Create an API token in your Cloudflare account:
   - Go to Cloudflare dashboard > My Profile > API Tokens
   - Create a new token with "Analytics Read" permissions
   - Copy the generated token

2. Update the `.env.cloudflare` file with your API token and domain:
   ```
   CF_API_TOKEN=your_cloudflare_api_token_here
   CF_DOMAINS=your-domain.com
   ```

3. Install the Cloudflare app in Grafana:
   - After starting the Grafana container, log in to the Grafana UI
   - Go to Configuration > Plugins
   - Search for "Cloudflare"
   - Install the Cloudflare app plugin

4. Restart the Grafana container:
   ```
   docker-compose restart grafana
   ```

5. Access the Cloudflare dashboard:
   - Go to Dashboards > Cloudflare > Cloudflare Domain Monitoring

### Troubleshooting

- If metrics don't appear, verify your API token has the correct permissions
- Check Grafana logs for any connection errors to the Cloudflare API
- Ensure your domain is correctly configured in the datasource
## Cloudflare Monitoring Setup

This setup allows you to monitor your Cloudflare domain metrics in Grafana using the Cloudflare exporter for Prometheus.

### Prerequisites

1. A Cloudflare account with at least one domain
2. API token with Analytics permissions

### Setup Instructions

1. Create an API token in your Cloudflare account:
   - Go to Cloudflare dashboard > My Profile > API Tokens
   - Create a new token with "Analytics Read" permissions
   - Copy the generated token

2. Update the `.env.cloudflare` file with your API token and domain:
   ```
   CF_API_TOKEN=your_cloudflare_api_token_here
   CF_DOMAINS=your-domain.com
   ```

3. Start the monitoring stack:
   ```
   docker-compose up -d
   ```

4. Access the Cloudflare dashboard:
   - Go to Grafana UI (http://localhost:3000)
   - Navigate to Dashboards > Cloudflare > Cloudflare Domain Monitoring

### Troubleshooting

- If metrics don't appear, verify your API token has the correct permissions
- Check the logs of the cloudflare-exporter container:
  ```
  docker-compose logs cloudflare-exporter
  ```
- Ensure your domain is correctly configured in the .env.cloudflare file
## Troubleshooting Cloudflare Exporter

If you encounter the error "lookup cloudflare-exporter on 127.0.0.11:53: server misbehaving", try these steps:

1. Restart the containers:
   ```
   docker-compose down
   docker-compose up -d
   ```

2. Check if the cloudflare-exporter container is running:
   ```
   docker-compose ps
   ```

3. Verify the exporter is accessible:
   ```
   chmod +x ./cloudflare-exporter-test.sh
   ./cloudflare-exporter-test.sh
   ```

4. If the container is failing, check the logs:
   ```
   docker-compose logs cloudflare-exporter
   ```

5. Try using the override configuration:
   ```
   docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d
   ```

6. Manually test the Cloudflare API with your token:
   ```
   curl -X GET "https://api.cloudflare.com/client/v4/zones" \
     -H "Authorization: Bearer $CF_API_TOKEN" \
     -H "Content-Type: application/json"
   ```
## Alternative Cloudflare Monitoring Setup

If you encounter issues with the Cloudflare exporter, try this alternative setup:

1. Use the systemli/prometheus-cloudflare-exporter image:
   ```
   docker-compose -f docker-compose.yml -f docker-compose.override.yml down
   docker-compose up -d
   ```

2. Or use the custom Python-based exporter:
   ```
   docker-compose -f docker-compose.yml -f docker-compose.cloudflare.yml up -d
   ```

3. Verify the exporter is working:
   ```
   curl http://localhost:9199/metrics
   ```

4. If you still have issues, try running the Python script directly:
   ```
   python cloudflare-script.py
   ```

The Python script is a simple alternative that doesn't rely on specific Docker images and should work with your Cloudflare API token.
## AWS Credentials Setup for Prometheus

To enable Prometheus to discover EC2 instances in your AWS account, you need to set up AWS credentials:

1. Create an IAM user with the following permissions:
   - `ec2:DescribeInstances`
   - `ec2:DescribeTags`

2. Generate an access key and secret key for this user

3. Add these credentials to the `.env.aws` file:
   ```
   AWS_ACCESS_KEY=your_aws_access_key_here
   AWS_SECRET_KEY=your_aws_secret_key_here
   ```

4. Restart Prometheus:
   ```
   docker-compose restart prometheus
   ```

5. Verify that targets are being discovered:
   - Go to Prometheus UI (http://your-server:9090)
   - Navigate to Status > Targets
   - Check that node-exporter-default and postgres-exporter-default have targets
## AWS Secrets Manager Integration

This setup uses AWS Secrets Manager to retrieve AWS credentials for Prometheus EC2 service discovery:

1. Ensure your server has an IAM role with the following permissions:
   - `secretsmanager:GetSecretValue` for the secret ARN: `arn:aws:secretsmanager:ap-southeast-1:533267407355:secret:aws/access_key/my_key-U0opHa`
   - `ec2:DescribeInstances`
   - `ec2:DescribeTags`

2. The secret in AWS Secrets Manager should have the following structure:
   ```json
   {
     "access_key": "YOUR_AWS_ACCESS_KEY",
     "secret_key": "YOUR_AWS_SECRET_KEY"
   }
   ```

3. Rebuild and restart the Prometheus container:
   ```
   docker-compose build prometheus
   docker-compose up -d prometheus
   ```

4. Verify that targets are being discovered:
   - Go to Prometheus UI (http://your-server:9090)
   - Navigate to Status > Targets
   - Check that node-exporter-default and postgres-exporter-default have targets