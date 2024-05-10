terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.48.0"
    }
  }

}

terraform {
  backend "s3" {
    bucket = "desafiotech01"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}


provider "aws" {
    region = var.aws_region
}

# Módulo VPC: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"
  name = var.aws_vpc_name
  cidr = var.aws_vpc_cidr

  azs             = var.aws_vpc_azs
  private_subnets = var.aws_vpc_private_subnets
  public_subnets  = var.aws_vpc_public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true
  
    tags = merge(local.tags, { "kubernetes.io/cluster/${var.aws_eks_name}" = "shared" })

    public_subnet_tags = {
    "kubernetes.io/cluster/${var.aws_eks_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.10.0"
  cluster_name = var.aws_eks_name
  cluster_version = var.aws_eks_version
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_private_access = true
  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id
  

  eks_managed_node_groups = {
     default    = {
      min_size     = 2
      max_size     = 2
      desired_size = 2
      instance_types = var.aws_eks_managed_node_groups_instance_types
      tags = local.tags
    }
  }
  
  tags = local.tags
}