#!/bin/sh

# Fetch AWS credentials from Secrets Manager
python3 /usr/local/bin/aws-secrets.py

# Start Prometheus with the original entrypoint
exec /bin/prometheus "$@"