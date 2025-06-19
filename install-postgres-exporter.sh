#!/bin/bash
# Quick PostgreSQL Exporter installation script for monitoring server

# Create user
sudo useradd --system --no-create-home --shell /bin/false postgres_exporter

# Download and install
cd /tmp
wget https://github.com/prometheus-community/postgres_exporter/releases/download/v0.13.1/postgres_exporter-0.13.1.linux-amd64.tar.gz
tar -xzf postgres_exporter-0.13.1.linux-amd64.tar.gz
sudo cp postgres_exporter-0.13.1.linux-amd64/postgres_exporter /usr/local/bin/
sudo chmod +x /usr/local/bin/postgres_exporter

# Create config directory and files
sudo mkdir -p /etc/postgres_exporter
sudo bash -c 'cat > /etc/postgres_exporter/postgres_exporter.env << EOF
DATA_SOURCE_NAME="postgresql://postgres@your-db-host:5432/postgres?sslmode=disable"
EOF'

# Create systemd service
sudo bash -c 'cat > /etc/systemd/system/postgres_exporter.service << EOF
[Unit]
Description=PostgreSQL Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=postgres_exporter
Group=postgres_exporter
Type=simple
EnvironmentFile=/etc/postgres_exporter/postgres_exporter.env
ExecStart=/usr/local/bin/postgres_exporter --web.listen-address=:9187

[Install]
WantedBy=multi-user.target
EOF'

# Start service
sudo systemctl daemon-reload
sudo systemctl enable postgres_exporter
sudo systemctl start postgres_exporter

