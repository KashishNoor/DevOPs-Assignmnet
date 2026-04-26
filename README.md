# DevOps A04 Terraform

Terraform infrastructure work for Assignment 04.

## Structure

- `A04/jenkins/terraform/00-bootstrap-state`: creates the S3 state bucket and locking resources.
- `A04/jenkins/terraform/01-base-infra`: creates the base AWS VPC, subnets, internet gateway, NAT gateway, and route tables.
- `A04/jenkins/terraform/02-jenkins-task1`: provisions the Jenkins controller in the public subnet and a Linux build agent in the private subnet.
- `A04/jenkins/plugins.txt`: Jenkins plugin inventory for Task 1.
- `A04/jenkins/setup.md`: Jenkins controller, agent, credentials, and plugin setup notes.
- `A04/jenkins/sanity-check.Jenkinsfile`: sanity pipeline that runs on the `linux-agent` node.
- `A04/app`: sample Node.js attendance API with unit and integration tests.
- `A04/jenkins/unitIntTest.Jenkinsfile`: Jenkins pipeline for build, unit tests, integration tests, and JUnit report publishing.

## Commands

Run bootstrap first if the remote state bucket does not exist:

```powershell
cd A04\jenkins\terraform\00-bootstrap-state
Copy-Item terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Then run base infrastructure:

```powershell
cd ..\01-base-infra
Copy-Item terraform.tfvars.example terraform.tfvars
terraform init -reconfigure
terraform fmt
terraform validate
terraform plan
terraform apply
```

Then run Jenkins Task 1 infrastructure:

```powershell
cd ..\02-jenkins-task1
Copy-Item terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set my_ip_cidr to your public IP, for example 1.2.3.4/32
terraform init -reconfigure
terraform fmt
terraform validate
terraform plan
terraform apply
```

After apply, use the `jenkins_url`, `jenkins_controller_public_ip`, and `jenkins_agent_private_ip` outputs to finish the Jenkins UI setup described in `A04/jenkins/setup.md`.

Run the application test suite locally:

```powershell
cd A04\app
npm ci
npm run build
npm run test:unit
npm run test:integration
```

The generated JUnit reports are stored under:

- `A04/app/reports/unit/junit.xml`
- `A04/app/reports/integration/junit.xml`

Webhook trigger test - 2026-04-25 21:44:28 +05:00
