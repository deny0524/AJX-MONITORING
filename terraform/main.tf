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
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
              echo "Starting user data script"
              
              # Update and install packages
              apt-get update
              apt-get install -y docker.io git curl
              systemctl enable docker
              systemctl start docker
              
              # Install Docker Compose v2
              mkdir -p /usr/local/lib/docker/cli-plugins
              curl -SL https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
              chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
              
              # Configure git to use the token for GitHub
              echo "Configuring git for private repository access"
              git config --global credential.helper store
              echo "https://${local.github_token}:x-oauth-basic@github.com" > /root/.git-credentials
              
              # Clone the monitoring repository
              echo "Cloning repository ${var.repo_url}"
              git clone ${var.repo_url} /opt/ajx-monitoring
              
              # Create .env file
              echo "Creating environment file"
              cat > /opt/ajx-monitoring/.env << 'ENVFILE'
              GF_SECURITY_ADMIN_USER=${var.grafana_admin_user}
              GF_SECURITY_ADMIN_PASSWORD=${var.grafana_admin_password}
              GF_USERS_ALLOW_SIGN_UP=false
              AWS_REGION=${var.aws_region}
              AWS_ACCESS_KEY_ID=${local.access_key}
              AWS_SECRET_ACCESS_KEY=${local.secret_key}
              ENVFILE
              
              # Start the monitoring stack
              echo "Starting monitoring stack"
              cd /opt/ajx-monitoring
              
              # Check if docker-compose.yml exists
              if [ -f "docker-compose.yml" ]; then
                echo "Found docker-compose.yml, starting services"
                docker compose up -d || docker-compose up -d
              else
                echo "ERROR: docker-compose.yml not found in repository"
                ls -la
              fi
              
              # Wait for services to start
              echo "Waiting for services to start..."
              sleep 30
              
              # Check if services are running
              echo "Checking running containers:"
              docker ps
              
              # Clean up credentials after use
              echo "Cleaning up credentials"
              rm -f /root/.git-credentials
              
              echo "User data script completed"
              EOF

  tags = {
    Name      = "ajx-monitoring-server"
    CreatedBy = "AJX-ENV-DEVTOOL"
  }
}