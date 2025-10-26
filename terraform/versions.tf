# ========================================
# Terraform and Provider Configuration
# ========================================

terraform {
  # Require Terraform version 1.0 or higher
  required_version = ">= 1.0"

  # Required providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # S3 Backend for Remote State Storage
  # This enables team collaboration and state locking
  backend "s3" {
    bucket         = "url-shortener-tfstate-094822715133"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    
    # Note: DynamoDB table for locking is optional for single-user setup
    # dynamodb_table = "terraform-state-lock"
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "URL-Shortener"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Team        = "DevOps"
    }
  }
}
