data "terraform_remote_state" "base" {
  backend = "s3"

  config = {
    bucket  = "kashish-devops-tfstate-188876037443"
    key     = "assignment-4/base-infra/terraform.tfstate"
    region  = "eu-north-1"
    encrypt = true
  }
}
