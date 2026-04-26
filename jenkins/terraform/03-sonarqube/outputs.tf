output "sonarqube_public_ip" {
  value = aws_instance.sonarqube.public_ip
}

output "sonarqube_private_ip" {
  value = aws_instance.sonarqube.private_ip
}

output "sonarqube_public_url" {
  value = "http://${aws_instance.sonarqube.public_ip}:9000"
}

output "sonarqube_private_url_for_jenkins" {
  value = "http://${aws_instance.sonarqube.private_ip}:9000"
}

output "sonarqube_webhook_url_for_jenkins" {
  value = "http://${data.aws_instance.jenkins_controller.private_ip}:8080/sonarqube-webhook/"
}