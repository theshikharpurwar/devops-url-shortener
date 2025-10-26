# ========================================
# VPC and Networking Infrastructure
# Using official AWS VPC module
# ========================================

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = [
    cidrsubnet(var.vpc_cidr, 8, 1),  # 10.0.1.0/24
    cidrsubnet(var.vpc_cidr, 8, 2),  # 10.0.2.0/24
  ]
  public_subnets = [
    cidrsubnet(var.vpc_cidr, 8, 101), # 10.0.101.0/24
    cidrsubnet(var.vpc_cidr, 8, 102), # 10.0.102.0/24
  ]

  # Enable DNS support (required for EKS)
  enable_dns_hostnames = true
  enable_dns_support   = true

  # NAT Gateway configuration
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  # Internet Gateway (automatically created for public subnets)
  create_igw = true

  # Enable VPC Flow Logs (optional, good for debugging)
  enable_flow_log                      = false
  create_flow_log_cloudwatch_iam_role  = false
  create_flow_log_cloudwatch_log_group = false

  # Tags for EKS cluster discovery
  public_subnet_tags = {
    "kubernetes.io/role/elb"                          = "1"
    "kubernetes.io/cluster/${var.project_name}-eks"   = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                 = "1"
    "kubernetes.io/cluster/${var.project_name}-eks"   = "shared"
  }

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# ========================================
# VPC Endpoints (Optional - Cost Optimization)
# Uncomment to enable private connectivity to AWS services
# ========================================

# resource "aws_vpc_endpoint" "s3" {
#   vpc_id       = module.vpc.vpc_id
#   service_name = "com.amazonaws.${var.aws_region}.s3"
#   route_table_ids = concat(
#     module.vpc.private_route_table_ids,
#     module.vpc.public_route_table_ids
#   )
#
#   tags = {
#     Name = "${var.project_name}-s3-endpoint"
#   }
# }

# resource "aws_vpc_endpoint" "ecr_api" {
#   vpc_id              = module.vpc.vpc_id
#   service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = module.vpc.private_subnets
#   security_group_ids  = [aws_security_group.vpc_endpoints.id]
#   private_dns_enabled = true
#
#   tags = {
#     Name = "${var.project_name}-ecr-api-endpoint"
#   }
# }
