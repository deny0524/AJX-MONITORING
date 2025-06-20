#!/bin/bash
# Script to configure nginx log forwarding to central Loki via syslog

LOKI_SERVER_IP="10.20.11.55"  # Replace with your Loki server IP
SYSLOG_PORT="1514"

echo "Configuring nginx log forwarding to $LOKI_SERVER_IP:$SYSLOG_PORT"

# Install rsyslog if not present
if ! command -v rsyslogd &> /dev/null; then
    echo "Installing rsyslog..."
    apt-get update && apt-get install -y rsyslog
fi

# Configure rsyslog to forward nginx logs
cat > /etc/rsyslog.d/49-nginx.conf << EOF
# Forward nginx access logs to central Loki
\$ModLoad imfile
\$InputFilePollInterval 1

# Nginx access log
\$InputFileName /var/log/nginx/access.log
\$InputFileTag nginx-access:
\$InputFileStateFile stat-nginx-access
\$InputFileSeverity info
\$InputFileFacility local0
\$InputRunFileMonitor

# Nginx error log
\$InputFileName /var/log/nginx/error.log
\$InputFileTag nginx-error:
\$InputFileStateFile stat-nginx-error
\$InputFileSeverity error
\$InputFileFacility local1
\$InputRunFileMonitor

# Forward to central server
local0.* @@$LOKI_SERVER_IP:$SYSLOG_PORT
local1.* @@$LOKI_SERVER_IP:$SYSLOG_PORT
EOF

# Restart rsyslog
systemctl restart rsyslog
systemctl enable rsyslog

echo "Log forwarding configured successfully"
echo "Nginx logs will be forwarded to $LOKI_SERVER_IP:$SYSLOG_PORT"