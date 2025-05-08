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