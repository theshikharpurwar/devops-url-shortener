# ========================================
# Jenkins CI/CD Server
# EC2 instance for running Jenkins
# ========================================

# Data source to get the latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ========================================
# Security Group for Jenkins Server
# ========================================

resource "aws_security_group" "jenkins" {
  name        = "${var.project_name}-jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = module.vpc.vpc_id

  # SSH access - temporarily open (close after setup)
  ingress {
    description = "SSH - TEMPORARY OPEN ACCESS"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins UI access (open to internet - restrict in production)
  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Application access on port 8001
  ingress {
    description = "URL Shortener Application"
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow communication with EKS cluster
  ingress {
    description = "Allow from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  # All outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-jenkins-sg"
    Environment = var.environment
  }
}

# ========================================
# IAM Role for Jenkins EC2 Instance
# ========================================

resource "aws_iam_role" "jenkins" {
  name = "${var.project_name}-jenkins-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-jenkins-role"
    Environment = var.environment
  }
}

# Attach policies for Jenkins to interact with AWS services
resource "aws_iam_role_policy_attachment" "jenkins_ecr" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# EKS policy removed - not using EKS in simplified setup

resource "aws_iam_role_policy_attachment" "jenkins_ssm" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create instance profile
resource "aws_iam_instance_profile" "jenkins" {
  name = "${var.project_name}-jenkins-profile"
  role = aws_iam_role.jenkins.name

  tags = {
    Name        = "${var.project_name}-jenkins-profile"
    Environment = var.environment
  }
}

# ========================================
# SSH Key Pair for Jenkins
# ========================================

# Note: Using existing key pair created via AWS CLI
# aws ec2 create-key-pair --key-name jenkins-server-key

# Uncomment below if you want Terraform to manage the key pair
# resource "aws_key_pair" "jenkins" {
#   key_name   = var.key_name
#   public_key = file("~/.ssh/id_rsa.pub")
#   tags = {
#     Name        = "${var.project_name}-jenkins-key"
#     Environment = var.environment
#   }
# }

# ========================================
# Jenkins EC2 Instance
# ========================================

resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.jenkins_instance_type

  # Network configuration
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.jenkins.id]
  associate_public_ip_address = true

  # IAM instance profile
  iam_instance_profile = aws_iam_instance_profile.jenkins.name

  # SSH key (using existing key pair from AWS)
  key_name = var.key_name

  # Root volume configuration
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name = "${var.project_name}-jenkins-root-volume"
    }
  }

  # User data script to install Docker and basic tools
  user_data = <<-EOF
              #!/bin/bash
              set -e
              
              # Update system
              apt-get update
              apt-get upgrade -y
              
              # Install basic tools
              apt-get install -y \
                curl \
                wget \
                git \
                unzip \
                vim \
                apt-transport-https \
                ca-certificates \
                gnupg \
                lsb-release
              
              # Install Docker
              curl -fsSL https://get.docker.com -o get-docker.sh
              sh get-docker.sh
              
              # Add ubuntu user to docker group
              usermod -aG docker ubuntu
              
              # Install Docker Compose
              curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose
              
              # Start and enable Docker
              systemctl start docker
              systemctl enable docker
              
              # Create a marker file to indicate user_data has run
              touch /var/log/user-data-complete.txt
              echo "User data script completed at $(date)" >> /var/log/user-data-complete.txt
              echo "Docker installed successfully" >> /var/log/user-data-complete.txt
              EOF

  # Metadata options for security
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name        = "${var.project_name}-jenkins-server"
    Environment = var.environment
    Purpose     = "CI/CD Server"
  }

  lifecycle {
    ignore_changes = [
      user_data,
      ami
    ]
  }
}

# ========================================
# Elastic IP for Jenkins (Optional)
# Uncomment if you want a static IP
# ========================================

# resource "aws_eip" "jenkins" {
#   instance = aws_instance.jenkins.id
#   domain   = "vpc"
#
#   tags = {
#     Name        = "${var.project_name}-jenkins-eip"
#     Environment = var.environment
#   }
#
#   depends_on = [aws_instance.jenkins]
# }
