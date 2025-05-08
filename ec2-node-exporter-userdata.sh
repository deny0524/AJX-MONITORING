#!/bin/bash

# This script can be used as EC2 user data to automatically install node_exporter
# on EC2 instances created with AJX-ENV-DEVTOOL

# Set variables
NODE_EXPORTER_VERSION="1.5.0"
NODE_EXPORTER_USER="node_exporter"
NODE_EXPORTER_GROUP="node_exporter"

# Update system
apt-get update
apt-get upgrade -y

# Create user and group
groupadd --system "$NODE_EXPORTER_GROUP"
useradd --system -g "$NODE_EXPORTER_GROUP" --no-create-home --shell /bin/false "$NODE_EXPORTER_USER"

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

# Add EC2 instance tags as node_exporter labels
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

# Install AWS CLI if not already installed
apt-get install -y awscli

# Get instance tags and convert to node_exporter labels
mkdir -p /etc/node_exporter

aws ec2 describe-tags --region $REGION --filters "Name=resource-id,Values=$INSTANCE_ID" --output json | \
jq -r '.Tags[] | "--collector.textfile.textfile-directory=/etc/node_exporter"' > /etc/node_exporter/node_exporter_args

# Create a cron job to update EC2 metadata every 5 minutes
cat > /etc/cron.d/node_exporter_metadata << EOF
*/5 * * * * root /usr/local/bin/update_node_exporter_metadata.sh
EOF

# Create the metadata update script
cat > /usr/local/bin/update_node_exporter_metadata.sh << 'EOF'
#!/bin/bash

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

# Get EC2 instance metadata
mkdir -p /etc/node_exporter
echo "# HELP ec2_instance_metadata EC2 instance metadata" > /etc/node_exporter/ec2_metadata.prom
echo "# TYPE ec2_instance_metadata gauge" >> /etc/node_exporter/ec2_metadata.prom

# Add instance metadata
aws ec2 describe-tags --region $REGION --filters "Name=resource-id,Values=$INSTANCE_ID" --output json | \
jq -r '.Tags[] | "ec2_instance_metadata{key=\"" + .Key + "\", value=\"" + .Value + "\"} 1"' >> /etc/node_exporter/ec2_metadata.prom
EOF

chmod +x /usr/local/bin/update_node_exporter_metadata.sh
/usr/local/bin/update_node_exporter_metadata.sh

echo "Node Exporter installed and running on port 9100"