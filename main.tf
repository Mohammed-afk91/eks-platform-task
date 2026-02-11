terraform {
  backend "s3" {
    bucket = "mohammed-platform-task-state-12345"  # <--- MUST MATCH THE BUCKET YOU CREATED
    key    = "public-repo-task/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "eu-west-1" # Or your preferred region
}

# 1. The Network Foundation
resource "aws_vpc" "platform_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "platform-learning-vpc"
  }
}

resource "aws_subnet" "platform_subnet" {
  vpc_id     = aws_vpc.platform_vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "platform-learning-subnet"
    Owner = "Mohammed"
  }
}

# Output the ID so we know it worked
output "vpc_id" {
  value = aws_vpc.platform_vpc.id
}

# 2. The Compute Layer (EKS Control Plane)
resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role-sim"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_eks_cluster" "platform_cluster" {
  name     = "platform-learning-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.platform_subnet.id]
  }
}