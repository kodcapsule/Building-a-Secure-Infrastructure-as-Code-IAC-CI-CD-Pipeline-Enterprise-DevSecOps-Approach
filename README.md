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
In this step, you will configure OpenID Connect (OIDC) authentication by setting up GitHub as the OpenID provider and integrating it with Amazon Web Services. This enables GitHub Actions to securely authenticate to AWS using short-lived credentials, eliminating the need for long-lived access keys.

Refer to this article, [Stop Storing AWS Access Keys in GitHub Secrets](https://github.com/kodcapsule/Zero-Trust-CI-CD-Using-OIDC-to-Authenticate-GitHub-Actions-to-AWS)
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

###  Using Terraform to  create S3 bucket
Alternatively you can create the S3 bucket using IaC.

**Step 1.** Create s3-backend.tf file
```bash
    touch infra/s3-backend/s3-backend.tf
```


**Step 2**  Create bucket
```bash
 terraform init
 terraform fmt
 terrafrom validate
 teraform plan
 terraform apply
```
**Step 3**  Verify that the backet has been created succesfull

### Create backend
**Step 1**  create backend.tf file
```bash
touch backend.tf
```
**Step 2**  Update the  backend




## CI/CD PIPELINE SETUP (GITHUB ACTIONS)
 