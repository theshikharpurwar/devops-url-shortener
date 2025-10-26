# ========================================
# AWS Elastic Container Registry (ECR)
# For storing Docker images
# ========================================

resource "aws_ecr_repository" "url_shortener_api" {
  name                 = "${var.project_name}-api"
  image_tag_mutability = "MUTABLE"

  # Image scanning configuration
  image_scanning_configuration {
    scan_on_push = true
  }

  # Encryption configuration
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "${var.project_name}-api"
    Environment = var.environment
    Purpose     = "Docker image repository for URL Shortener API"
  }
}

# ========================================
# ECR Lifecycle Policy
# Automatically clean up old images to save storage costs
# ========================================

resource "aws_ecr_lifecycle_policy" "url_shortener_api_policy" {
  repository = aws_ecr_repository.url_shortener_api.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images older than 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ========================================
# ECR Repository Policy (Optional)
# Allow EKS cluster to pull images
# ========================================

data "aws_iam_policy_document" "ecr_policy" {
  statement {
    sid    = "AllowEKSPull"
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "eks.amazonaws.com",
        "ec2.amazonaws.com"
      ]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages"
    ]
  }
}

resource "aws_ecr_repository_policy" "url_shortener_api_policy" {
  repository = aws_ecr_repository.url_shortener_api.name
  policy     = data.aws_iam_policy_document.ecr_policy.json
}
