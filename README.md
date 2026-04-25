# DevOps A04 Terraform

Terraform infrastructure work for Assignment 04.

## Structure

- `A04/jenkins/terraform/00-bootstrap-state`: creates the S3 state bucket and locking resources.
- `A04/jenkins/terraform/01-base-infra`: creates the base AWS VPC, subnets, internet gateway, NAT gateway, and route tables.

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

