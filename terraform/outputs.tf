# ========================================
# Terraform Outputs
# Display important resource information
# ========================================

# ========================================
# VPC Outputs
# ========================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

# ========================================
# ECR Outputs
# ========================================

output "ecr_repository_url" {
  description = "URL of the ECR repository for the URL Shortener API"
  value       = aws_ecr_repository.url_shortener_api.repository_url
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.url_shortener_api.name
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.url_shortener_api.arn
}

# ========================================
# Jenkins Outputs
# ========================================

output "jenkins_public_ip" {
  description = "Public IP address of the Jenkins server"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_public_dns" {
  description = "Public DNS of the Jenkins server"
  value       = aws_instance.jenkins.public_dns
}

output "jenkins_ssh_command" {
  description = "SSH command to connect to Jenkins server"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.jenkins.public_ip}"
}

output "jenkins_ui_url" {
  description = "URL to access Jenkins UI"
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "jenkins_security_group_id" {
  description = "Security group ID for Jenkins server"
  value       = aws_security_group.jenkins.id
}

# ========================================
# EKS Cluster Outputs - DISABLED (Simplified Setup)
# ========================================
# Using Docker on Jenkins server instead of EKS to avoid Free Tier restrictions

# ========================================
# DocumentDB Outputs - DISABLED FOR COST SAVINGS
# ========================================
# DocumentDB has been removed to reduce costs and simplify deployment
# The application can use in-memory storage or connect to an external MongoDB instance

# ========================================
# General Information
# ========================================

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

# ========================================
# Quick Reference Guide
# ========================================

output "quick_reference" {
  description = "Quick reference commands for managing your infrastructure"
  value = <<-EOT
  
  ========================================
  🚀 INFRASTRUCTURE DEPLOYED SUCCESSFULLY (SIMPLIFIED SETUP)
  ========================================
  
  📦 ECR Repository:
     ${aws_ecr_repository.url_shortener_api.repository_url}
     
     Login to ECR:
     aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${split("/", aws_ecr_repository.url_shortener_api.repository_url)[0]}
  
  🖥️  Jenkins Server (with Docker):
     UI:  http://${aws_instance.jenkins.public_ip}:8080
     SSH: ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_instance.jenkins.public_ip}
     
     Docker installed and ready to deploy containerized applications!
  
  ========================================
  Next Steps:
  1. SSH to Jenkins server
  2. Configure Jenkins (Phase 3 - Ansible)
  3. Set up CI/CD pipeline (Phase 4)
  4. Deploy application using Docker on Jenkins
  ========================================
  
  EOT
}
