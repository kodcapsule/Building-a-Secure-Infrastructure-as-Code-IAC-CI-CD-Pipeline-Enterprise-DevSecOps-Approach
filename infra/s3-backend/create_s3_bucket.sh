#!/bin/bash

# =============================================================
# Script: create_s3_bucket.sh
# Description: Creates an S3 bucket using the AWS CLI
# Usage: ./create_s3_bucket.sh <region> <bucket-name>
# =============================================================

# ---- Colors for output ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ---- Helper functions ----
info()    { echo -e "${CYAN}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC}  $1"; exit 1; }

# ---- Banner ----
echo -e "${CYAN}"
echo "============================================="
echo "        S3 Bucket Creation Script           "
echo "============================================="
echo -e "${NC}"

# ---- Check arguments ----
if [ "$#" -ne 2 ]; then
    echo -e "${YELLOW}Usage:${NC} ./create_s3_bucket.sh <region> <bucket-name>"
    echo ""
    echo "  Example: ./create_s3_bucket.sh us-east-1 my-secure-bucket"
    echo ""
    error "Exactly 2 arguments required: region and bucket name."
fi

REGION=$1
BUCKET_NAME=$2

# ---- Validate bucket name (basic AWS rules) ----
info "Validating bucket name..."
if [[ ! "$BUCKET_NAME" =~ ^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$ ]]; then
    error "Invalid bucket name '$BUCKET_NAME'. Must be 3-63 chars, lowercase letters, numbers, hyphens, or dots."
fi
success "Bucket name is valid."

# ---- Check AWS CLI is installed ----
info "Checking if AWS CLI is installed..."
if ! command -v aws &>/dev/null; then
    error "AWS CLI is not installed. Install it from: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html"
fi
AWS_VERSION=$(aws --version 2>&1)
success "AWS CLI found: $AWS_VERSION"

# ---- Check AWS CLI is configured ----
info "Checking if AWS CLI is configured..."
if ! aws sts get-caller-identity &>/dev/null; then
    error "AWS CLI is not configured or credentials are invalid. Run 'aws configure' to set up."
fi
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
success "AWS CLI configured. Account ID: $ACCOUNT_ID"

# ---- Check if bucket already exists ----
info "Checking if bucket '$BUCKET_NAME' already exists..."
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    warning "Bucket '$BUCKET_NAME' already exists. Skipping creation."
    exit 0
fi
info "Bucket does not exist. Proceeding with creation..."

# ---- Create the S3 bucket ----
info "Creating S3 bucket '$BUCKET_NAME' in region '$REGION'..."

# us-east-1 does not accept a LocationConstraint
if [ "$REGION" == "us-east-1" ]; then
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$REGION" \
        &>/dev/null
else
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$REGION" \
        --create-bucket-configuration LocationConstraint="$REGION" \
        &>/dev/null
fi

if [ $? -ne 0 ]; then
    error "Failed to create bucket '$BUCKET_NAME'. Check your permissions and region."
fi
success "Bucket '$BUCKET_NAME' created successfully."

# ---- Enable versioning ----
info "Enabling versioning on '$BUCKET_NAME'..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled &>/dev/null
success "Versioning enabled."

# ---- Block all public access ----
info "Blocking all public access on '$BUCKET_NAME'..."
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
        "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" &>/dev/null
success "Public access blocked."

# ---- Enable server-side encryption ----
info "Enabling server-side encryption (AES-256) on '$BUCKET_NAME'..."
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }' &>/dev/null
success "Server-side encryption enabled."

# ---- Summary ----
echo ""
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}         Bucket Setup Complete!             ${NC}"
echo -e "${GREEN}=============================================${NC}"
echo -e "  ${CYAN}Bucket Name:${NC}  $BUCKET_NAME"
echo -e "  ${CYAN}Region:${NC}       $REGION"
echo -e "  ${CYAN}Account ID:${NC}   $ACCOUNT_ID"
echo -e "  ${CYAN}Versioning:${NC}   Enabled"
echo -e "  ${CYAN}Public Access:${NC} Blocked"
echo -e "  ${CYAN}Encryption:${NC}   AES-256"
echo -e "${GREEN}=============================================${NC}"