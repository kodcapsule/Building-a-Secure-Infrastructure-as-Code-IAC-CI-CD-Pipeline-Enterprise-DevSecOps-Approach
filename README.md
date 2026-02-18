# Building a Secure Infrastructure as Code (IAC) CI/CD Pipeline: Enterprise DevSecOps Approach
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
 
## AUTHENTICATION (CONFIGURE OICD for AWS)
## CONFIGURE REMOTE BACKEND / STATE MANAGEMENT
  Make sure your have Installed and Configure AWS CLI  and Terraform 
###  Using AWS CLI
*Step 1* Create the S3 Bucket

Create S3 bucket with this command
```bash
aws s3api create-bucket \
  --bucket <UIQUE_S3_BUCKET_NAME> \
  --region <AWS_REGION>
```
*Step 2* Enable S3 bucket Versioning

```bash
aws s3api put-bucket-versioning \
  --bucket <UIQUE_S3_BUCKET_NAME> \
  --versioning-configuration Status=Enabled
```

*Step 3* Enable Encryption
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

*Step 4*  Block Public Access

```bash
aws s3api put-public-access-block \
  --bucket <UIQUE_S3_BUCKET_NAME> \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

```
*Step 5*  verify 
```bash
aws s3 ls s3://<UIQUE_S3_BUCKET_NAME>/global/s3/
```

###  Using Terraform



## CI/CD PIPELINE SETUP (GITHUB ACTIONS)
 