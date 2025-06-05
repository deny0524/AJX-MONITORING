#!/bin/bash

# Test script to verify Cloudflare exporter is working
# Run this from the host machine to check if the exporter is accessible

echo "Testing connection to Cloudflare exporter..."
curl http://localhost:9199/metrics

echo -e "\n\nChecking if environment variables are set correctly..."
docker-compose exec cloudflare-exporter env | grep CF_

echo -e "\n\nChecking logs from cloudflare-exporter..."
docker-compose logs cloudflare-exporter