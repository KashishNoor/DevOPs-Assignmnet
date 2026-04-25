# Jenkins Controller and Agent Setup

## Overview

This setup provisions a Jenkins controller and one Linux build agent inside the Terraform-managed Assignment 3 VPC.

## Infrastructure

- Jenkins controller runs on an EC2 instance in a public subnet.
- Jenkins agent runs on a separate EC2 instance in a private subnet.
- Port 8080 on the controller is open only to the student's public IP.
- Port 22 on the controller is open only to the student's public IP.
- Port 22 on the agent is open only from the Jenkins controller security group.
- The Jenkins agent is connected to the controller through SSH.
- The Jenkins agent label is `linux-agent`.

## Installed software

The controller user_data script installs:

- Java 21
- Git
- Docker
- AWS CLI
- Terraform
- Jenkins LTS

The agent user_data script installs:

- Java 21
- Git
- Docker
- AWS CLI
- Terraform

## Jenkins setup steps

1. Provision the controller and agent EC2 instances using Terraform.
2. Open the Jenkins controller URL on port 8080.
3. Unlock Jenkins using `/var/lib/jenkins/secrets/initialAdminPassword`.
4. Install suggested plugins.
5. Install and verify the required plugins:
   - Pipeline
   - Git
   - GitHub Branch Source
   - Docker Pipeline
   - Credentials Binding
   - Pipeline Utility Steps
   - SonarQube Scanner
   - Blue Ocean
6. Create the admin user.
7. Add global credentials:
   - `jenkins-agent-ssh-key`
   - `aws-credentials`
   - `github-pat`
   - `slack-webhook-url`
   - `sonarqube-token`
   - `ecr-registry-placeholder`
8. Configure GitHub under Manage Jenkins > System using `github-pat`.
9. Add a permanent node named `linux-agent`.
10. Configure the node to launch via SSH using the agent private IP.
11. Run the sanity-check pipeline from `jenkins/sanity-check.Jenkinsfile`.

## Sanity check

The sanity-check pipeline runs on the `linux-agent` label and verifies:

- Java
- Git
- Docker
- AWS CLI
- Terraform