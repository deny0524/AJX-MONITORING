#!/bin/bash

# This script installs and configures node_exporter on EC2 instances
# Run this script on your EC2 instances created with AJX-ENV-DEVTOOL

# Set variables
NODE_EXPORTER_VERSION="1.5.0"
NODE_EXPORTER_USER="node_exporter"
NODE_EXPORTER_GROUP="node_exporter"

# Create user and group
if ! getent group "$NODE_EXPORTER_GROUP" > /dev/null 2>&1; then
  groupadd --system "$NODE_EXPORTER_GROUP"
fi

if ! getent passwd "$NODE_EXPORTER_USER" > /dev/null 2>&1; then
  useradd --system -g "$NODE_EXPORTER_GROUP" --no-create-home --shell /bin/false "$NODE_EXPORTER_USER"
fi

# Download and install node_exporter
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
tar xvfz node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/
chown ${NODE_EXPORTER_USER}:${NODE_EXPORTER_GROUP} /usr/local/bin/node_exporter

# Clean up
rm -rf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64*

# Create systemd service
cat > /etc/systemd/system/node_exporter.service << EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=${NODE_EXPORTER_USER}
Group=${NODE_EXPORTER_GROUP}
Type=simple
ExecStart=/usr/local/bin/node_exporter --collector.filesystem.ignored-mount-points="^/(dev|proc|sys|var/lib/docker/.+)($|/)" --collector.filesystem.ignored-fs-types="^(autofs|binfmt_misc|cgroup|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|mqueue|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|sysfs|tracefs)$"

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

echo "Node Exporter installed and running on port 9100"