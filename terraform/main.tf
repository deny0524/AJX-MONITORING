provider "aws" {
  region = var.aws_region
}

# Create an Internet Gateway
resource "aws_internet_gateway" "monitoring_igw" {
  vpc_id = "vpc-0c18c395b2b7ceedb"
  
  tags = {
    Name = "ajx-monitoring-igw"
  }
}

# Create a route table
resource "aws_route_table" "monitoring_rt" {
  vpc_id = "vpc-0c18c395b2b7ceedb"
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.monitoring_igw.id
  }
  
  tags = {
    Name = "ajx-monitoring-rt"
  }
}

# Associate the route table with your subnet
resource "aws_route_table_association" "monitoring_rta" {
  subnet_id      = var.subnet_id
  route_table_id = aws_route_table.monitoring_rt.id
}

resource "aws_security_group" "monitoring_sg" {
  name        = "ajx-monitoring-sg"
  description = "Security group for AJX monitoring stack"
  vpc_id      = "vpc-0c18c395b2b7ceedb"

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["139.162.51.246/32", "0.0.0.0/0"]
    description = "Prometheus"
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["139.162.51.246/32", "0.0.0.0/0"]
    description = "Grafana"
  }

  ingress {
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["139.162.51.246/32", "0.0.0.0/0"]
    description = "AlertManager"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["139.162.51.246/32"]
    description = "SSH"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "ajx-monitoring-sg"
    CreatedBy = "AJX-ENV-DEVTOOL"
  }
}

resource "aws_instance" "monitoring_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.monitoring_sg.id]
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Redirect output to both console and log file
              exec > >(tee /var/log/user-data.log) 2>&1
              echo "Starting monitoring stack setup at $(date)"
              
              # Check if the script has already run
              if [ -f "/opt/ajx-monitoring/.setup_complete" ]; then
                echo "Setup already completed. Exiting."
                exit 0
              fi
              
              # Update and install packages
              echo "Updating packages..."
              apt-get update
              apt-get install -y docker.io curl jq
              
              # Make sure Docker is running
              echo "Ensuring Docker is running..."
              systemctl enable docker
              systemctl start docker
              sleep 5
              
              # Verify Docker is running
              if ! systemctl is-active --quiet docker; then
                echo "ERROR: Docker is not running. Attempting to start..."
                systemctl start docker
                sleep 5
                
                if ! systemctl is-active --quiet docker; then
                  echo "ERROR: Failed to start Docker. Exiting."
                  exit 1
                fi
              fi
              
              # Install Docker Compose v2
              echo "Installing Docker Compose..."
              mkdir -p /usr/local/lib/docker/cli-plugins
              curl -SL https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
              chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
              
              # Create monitoring directory
              echo "Creating monitoring directory structure..."
              mkdir -p /opt/ajx-monitoring
              mkdir -p /opt/ajx-monitoring/prometheus
              mkdir -p /opt/ajx-monitoring/alertmanager
              
              # Create .env file
              echo "Creating environment file..."
              cat > /opt/ajx-monitoring/.env << ENVFILE
              GF_SECURITY_ADMIN_USER=${var.grafana_admin_user}
              GF_SECURITY_ADMIN_PASSWORD=${var.grafana_admin_password}
              GF_USERS_ALLOW_SIGN_UP=false
              AWS_REGION=${var.aws_region}
              AWS_ACCESS_KEY_ID=${local.access_key}
              AWS_SECRET_ACCESS_KEY=${local.secret_key}
              ENVFILE
              
              # Create docker-compose.yml
              echo "Creating docker-compose.yml..."
              cat > /opt/ajx-monitoring/docker-compose.yml << 'DOCKER_COMPOSE'
              version: '3'
              
              services:
                prometheus:
                  image: prom/prometheus:latest
                  container_name: prometheus
                  ports:
                    - "9090:9090"
                  volumes:
                    - ./prometheus:/etc/prometheus
                    - prometheus_data:/prometheus
                  command:
                    - '--config.file=/etc/prometheus/prometheus.yml'
                    - '--storage.tsdb.path=/prometheus'
                    - '--web.console.libraries=/etc/prometheus/console_libraries'
                    - '--web.console.templates=/etc/prometheus/consoles'
                    - '--web.enable-lifecycle'
                  restart: unless-stopped
              
                alertmanager:
                  image: prom/alertmanager:latest
                  container_name: alertmanager
                  ports:
                    - "9093:9093"
                  volumes:
                    - ./alertmanager:/etc/alertmanager
                  command:
                    - '--config.file=/etc/alertmanager/alertmanager.yml'
                    - '--storage.path=/alertmanager'
                  restart: unless-stopped
              
                grafana:
                  image: grafana/grafana:latest
                  container_name: grafana
                  ports:
                    - "3000:3000"
                  environment:
                    - GF_SECURITY_ADMIN_USER=admin
                    - GF_SECURITY_ADMIN_PASSWORD=admin
                    - GF_USERS_ALLOW_SIGN_UP=false
                  volumes:
                    - grafana_data:/var/lib/grafana
                  restart: unless-stopped
              
              volumes:
                prometheus_data:
                grafana_data:
              DOCKER_COMPOSE
              
              # Create prometheus.yml
              echo "Creating prometheus.yml..."
              cat > /opt/ajx-monitoring/prometheus/prometheus.yml << 'PROMETHEUS_CONFIG'
              global:
                scrape_interval: 15s
                evaluation_interval: 15s
              
              alerting:
                alertmanagers:
                  - static_configs:
                      - targets:
                          - alertmanager:9093
              
              rule_files:
                - "rules/*.yml"
              
              scrape_configs:
                - job_name: 'prometheus'
                  static_configs:
                    - targets: ['localhost:9090']
              
                - job_name: 'node'
                  static_configs:
                    - targets: ['localhost:9100']
              PROMETHEUS_CONFIG
              
              # Create alertmanager.yml
              echo "Creating alertmanager.yml..."
              cat > /opt/ajx-monitoring/alertmanager/alertmanager.yml << 'ALERTMANAGER_CONFIG'
              global:
                resolve_timeout: 5m
              
              route:
                group_by: ['alertname']
                group_wait: 30s
                group_interval: 5m
                repeat_interval: 1h
                receiver: 'web.hook'
              
              receivers:
                - name: 'web.hook'
                  webhook_configs:
                    - url: 'http://127.0.0.1:5001/'
              
              inhibit_rules:
                - source_match:
                    severity: 'critical'
                  target_match:
                    severity: 'warning'
                  equal: ['alertname', 'dev', 'instance']
              ALERTMANAGER_CONFIG
              
              # Pull Docker images before starting
              echo "Pulling Docker images..."
              docker pull prom/prometheus:latest
              docker pull prom/alertmanager:latest
              docker pull grafana/grafana:latest
              
              # Start the monitoring stack
              echo "Starting monitoring stack..."
              cd /opt/ajx-monitoring
              docker compose up -d || docker-compose up -d
              
              # Check if containers are running
              echo "Checking if containers are running..."
              sleep 10
              RUNNING_CONTAINERS=$(docker ps --format "{{.Names}}" | grep -E 'prometheus|alertmanager|grafana' | wc -l)
              
              if [ "$RUNNING_CONTAINERS" -eq 3 ]; then
                echo "All containers are running successfully!"
              else
                echo "WARNING: Not all containers are running. Current status:"
                docker ps
                echo "Container logs:"
                docker logs prometheus
                docker logs alertmanager
                docker logs grafana
              fi
              
              # Mark setup as complete
              touch /opt/ajx-monitoring/.setup_complete
              
              echo "User data script completed at $(date)"
              EOF

  tags = {
    Name      = "ajx-monitoring-server"
    CreatedBy = "AJX-ENV-DEVTOOL"
  }
}