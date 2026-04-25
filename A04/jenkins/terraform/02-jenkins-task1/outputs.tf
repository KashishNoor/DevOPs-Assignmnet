output "jenkins_controller_public_ip" {
  description = "Public IP of Jenkins controller"
  value       = aws_instance.jenkins_controller.public_ip
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://${aws_instance.jenkins_controller.public_ip}:8080"
}

output "jenkins_agent_private_ip" {
  description = "Private IP of Jenkins agent"
  value       = aws_instance.jenkins_agent.private_ip
}

output "jenkins_private_key_file" {
  description = "Local private key file for Jenkins EC2 instances"
  value       = local_sensitive_file.jenkins_private_key.filename
  sensitive   = true
}