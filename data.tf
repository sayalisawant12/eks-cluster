# Data block to fetch the default VPC
data "aws_vpc" "default" {
  default = true
}

# Data block to fetch subnets of the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Data block to fetch the latest Amazon EKS-optimized AMI
data "aws_ami" "eks_optimized" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.k8s_version}*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["602401143452"] # Amazon EKS AMI owner ID
} 
