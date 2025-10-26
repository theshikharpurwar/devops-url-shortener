#!/bin/bash

# ========================================
# S3 Backend Setup Script
# Run this ONCE before using Terraform
# ========================================

set -e

# Configuration
BUCKET_NAME="my-team-url-shortener-tfstate"
DYNAMODB_TABLE="terraform-state-lock"
AWS_REGION="us-east-1"

echo "========================================="
echo "Setting up Terraform S3 Backend"
echo "========================================="
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ ERROR: AWS CLI is not installed."
    echo "Install it with: sudo apt-get install awscli"
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ ERROR: AWS credentials are not configured."
    echo "Run: aws configure"
    exit 1
fi

echo "✅ AWS CLI is configured"
echo ""

# Create S3 bucket for Terraform state
echo "📦 Creating S3 bucket: $BUCKET_NAME..."

if aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'; then
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$AWS_REGION"
    
    echo "✅ S3 bucket created: $BUCKET_NAME"
else
    echo "⚠️  S3 bucket already exists: $BUCKET_NAME"
fi

# Enable versioning on the bucket
echo "🔄 Enabling versioning on S3 bucket..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled \
    --region "$AWS_REGION"

echo "✅ Versioning enabled"

# Enable encryption
echo "🔐 Enabling server-side encryption..."
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }' \
    --region "$AWS_REGION"

echo "✅ Encryption enabled"

# Block public access
echo "🔒 Blocking public access..."
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
        "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
    --region "$AWS_REGION"

echo "✅ Public access blocked"

# Create DynamoDB table for state locking
echo "🔐 Creating DynamoDB table for state locking: $DYNAMODB_TABLE..."

if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" --region "$AWS_REGION" &> /dev/null; then
    echo "⚠️  DynamoDB table already exists: $DYNAMODB_TABLE"
else
    aws dynamodb create-table \
        --table-name "$DYNAMODB_TABLE" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region "$AWS_REGION"
    
    echo "✅ DynamoDB table created: $DYNAMODB_TABLE"
fi

echo ""
echo "========================================="
echo "✅ S3 Backend Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Review terraform.tfvars.example"
echo "2. Create terraform.tfvars with your settings"
echo "3. Run: terraform init"
echo "4. Run: terraform plan"
echo "5. Run: terraform apply"
echo ""
