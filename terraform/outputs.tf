output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.flask_server.public_ip
}

output "application_url" {
  description = "URL to access the deployed Flask webpage"
  value       = "http://${aws_instance.flask_server.public_ip}"
}

output "health_check_url" {
  description = "URL for the Flask health check endpoint"
  value       = "http://${aws_instance.flask_server.public_ip}/health"
}
