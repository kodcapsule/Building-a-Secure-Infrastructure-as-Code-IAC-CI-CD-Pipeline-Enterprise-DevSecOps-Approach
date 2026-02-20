# Building a Secure Infrastructure as Code IAC CI/CD Pipeline: Enterprise DevSecOps Approach
## Introduction 


## Prerequisites for IaC CI/CD Pipeline
This project is not beginner-friendly. Before starting this project, make sure you have the following:
1. A GitHub account
2. An AWS account with sufficient IAM permissions to create a VPC and EKS
3. Install HashiCorp Terraform, the pre-commit framework, and Gitleaks
4. A code editor (VS Code recommended)
5. Basic knowledge of Infrastructure as Code (Terraform basics), CI/CD concepts, Git and Git workflows, and AWS cloud fundamentals
 


## LOCAL SETUP
A reliable and secure IaC pipeline always starts locally before code reaches remote  repos. Shift-Left Security ensures that, potential issues are caught early, reducing pipeline failures and preventing insecure code from being committed. In your local development environment, configure:

 1. Pre-commit hooks: Using pre-commit framework
 2. Secrets detection : Tools like Gitleaks to catch hardcoded credentials
 3. Linting and formatting : Ensuring consistent, clean, and error-free code

 Implementig these local checks, ensures that  security and quality issues are caught early and making the entire IaC pipeline safer, faster, and more reliable
 
## AUTHENTICATION: CONFIGURE OpenID Connect (OIDC) for AWS
In this step, you will configure OpenID Connect (OIDC) authentication by setting up GitHub as the OpenID provider and integrating it with AWS. This enables GitHub Actions to securely authenticate to AWS using short-lived credentials, which is the best practices.

Refer to this article, [Stop Storing AWS Access Keys in GitHub Secrets — Use OIDC Instead to Authenticate GitHub Actions to AWS](https://github.com/kodcapsule/Zero-Trust-CI-CD-Using-OIDC-to-Authenticate-GitHub-Actions-to-AWS)
, for a complete step-by-step process for setting up OIDC.

## CONFIGURE REMOTE BACKEND / STATE MANAGEMENT
  Make sure your have Installed and Configure AWS CLI  and Terraform 
###  Using AWS CLI to create S3 state bucket
Create S3 bucket using the AWS CLI with the bellow commands:

**Step 1** Create the S3 Bucket
```bash
aws s3api create-bucket \
  --bucket <UIQUE_S3_BUCKET_NAME> \
  --region <AWS_REGION>
```
**Step 2** Enable S3 bucket Versioning
```bash
aws s3api put-bucket-versioning \
  --bucket <UIQUE_S3_BUCKET_NAME> \
  --versioning-configuration Status=Enabled
```

**Step 3** Enable Encryption
```bash
aws s3api put-bucket-encryption \
  --bucket <UIQUE_S3_BUCKET_NAME> \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

**Step 4**  Block Public Access
```bash
aws s3api put-public-access-block \
  --bucket <UIQUE_S3_BUCKET_NAME> \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

```
**Step 5**  verify 
```bash
aws s3 ls s3://<UIQUE_S3_BUCKET_NAME>/global/s3/
```
Alternatively you can run this script `infra/create_s3_bucket.sh` to create the bucket

### Create backend
**Step 1**  create backend.tf file
```bash
touch infra/backend.tf
```
**Step 2**  Update the  backend

```bash
# infra/backend.tf

terraform {
  backend "s3" {
    bucket         = "remote-state-bucket-kodecapsule-for-eks-102"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  

  }

  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```
## CI/CD PIPELINE SETUP (GITHUB ACTIONS)
This is the major step in this project. We will setup the CI/CD pipeline using GitHub Actions to automate the validation, security scanning, testing, and deployment of the IaC code. 

### Setting up of Gitleaks


GitHub Actions will execute a series of defined workflows whenever code is pushed or a pull request is created, ensuring that all security checks, compliance policies, and quality gates are enforced before deployment to Amazon Web Services.

This automated pipeline helps ensure consistent, secure, and reliable infrastructure deployments across development, staging, and production environments.


 