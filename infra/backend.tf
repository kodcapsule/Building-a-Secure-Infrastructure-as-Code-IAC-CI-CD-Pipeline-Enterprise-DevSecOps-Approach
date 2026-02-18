# terraform/backend.tf

terraform {
  backend "s3" {
    bucket         = "remote-state-bucket-kodecapsule-for-eks-102"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile = true
  

  }

  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}