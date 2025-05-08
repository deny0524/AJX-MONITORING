output "monitoring_server_id" {
  description = "ID of the monitoring server"
  value       = aws_instance.monitoring_server.id
}

output "monitoring_server_public_ip" {
  description = "Public IP address of the monitoring server"
  value       = aws_instance.monitoring_server.public_ip
}

output "monitoring_server_private_ip" {
  description = "Private IP address of the monitoring server"
  value       = aws_instance.monitoring_server.private_ip
}

output "grafana_url" {
  description = "URL to access Grafana"
  value       = "http://${aws_instance.monitoring_server.public_ip}:3000"
}

output "prometheus_url" {
  description = "URL to access Prometheus"
  value       = "http://${aws_instance.monitoring_server.public_ip}:9090"
}

output "alertmanager_url" {
  description = "URL to access AlertManager"
  value       = "http://${aws_instance.monitoring_server.public_ip}:9093"
}