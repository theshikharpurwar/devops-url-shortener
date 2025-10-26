# ========================================
# Input Variables
# ========================================

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "url-shortener"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "jenkins_allowed_ip" {
  description = "Your IP address for SSH and Jenkins UI access (format: x.x.x.x/32)"
  type        = string
  default     = "YOUR_IP_ADDRESS/32"
}

variable "jenkins_instance_type" {
  description = "EC2 instance type for Jenkins server"
  type        = string
  default     = "t2.medium"
}

variable "key_name" {
  description = "Name of the SSH key pair for EC2 instances"
  type        = string
  default     = "jenkins-server-key"
}

variable "eks_node_instance_type" {
  description = "EC2 instance type for EKS nodes"
  type        = string
  default     = "t3.medium"
}

variable "eks_desired_nodes" {
  description = "Desired number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "eks_min_nodes" {
  description = "Minimum number of EKS worker nodes"
  type        = number
  default     = 1
}

variable "eks_max_nodes" {
  description = "Maximum number of EKS worker nodes"
  type        = number
  default     = 4
}

variable "docdb_instance_class" {
  description = "DocumentDB instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "docdb_instance_count" {
  description = "Number of DocumentDB instances"
  type        = number
  default     = 1
}

variable "docdb_master_username" {
  description = "Master username for DocumentDB"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "docdb_username" {
  description = "Alias for DocumentDB master username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "eks_cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.30"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway to save costs (not recommended for production)"
  type        = bool
  default     = true
}
