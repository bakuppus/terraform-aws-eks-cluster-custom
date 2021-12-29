###################################################################################
# AWS VPC
###################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                        = "1"
    "kubernetes.io/role/elb"                        = "1"
    "subnet"                                        = "public"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"               = "1"
    "kubernetes.io/role/elb"                        = "1"
    "subnet"                                        = "private"
  }

  tags = {
    Environment = var.environment
    Terraform   = true
  }
}

###################################################################################
# AWS EKS Module
###################################################################################



module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "17.24.0"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false
  cluster_enabled_log_types = ["api"]
  cluster_log_retention_in_days = "7"
  cluster_iam_role_name = aws_iam_role.cluster_role.name


  node_groups = {
    private = {
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1
      disk_size        = 30
      instance_types = ["t2.medium"]
      capacity_type  = "ON_DEMAND"
      k8s_labels = {
        node_group_type = "private_node_groups"
      }
      workers_role_name  = aws_iam_role.worker_role.name
      subnets = module.vpc.private_subnets
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      additional_tags = {
        ExtraTag = "private"
      }
    }
    public = {
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1
      disk_size        = 30
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      k8s_labels = {
        node_group_type    = "public_node_groups"
      }
      workers_role_name  = aws_iam_role.worker_role.name
      subnets = module.vpc.public_subnets
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      additional_tags = {
        ExtraTag = "public"
      }
    }
  }

  tags = {
    Environment = var.environment
    Owner = var.owner
    Terraform   = true
  }
}

######################################
#IAM CLUSTER ROLE/POLICY
######################################
resource "aws_iam_role" "cluster_role" {
  name = "eks-cluster_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "cluster_policy" {
  name        = "eks-cluster-policy"
  description = "A EKS policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "eks:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks-cluster_attach" {
  role       = aws_iam_role.cluster_role.name
  policy_arn = aws_iam_policy.cluster_policy.arn
}
######################################
#IAM  ROLE/POLICY
######################################




resource "aws_iam_role" "worker_role" {
  name = "eks-worker_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "worker_policy" {
  name        = "eks-worker-policy"
  description = "A EKS policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "eks:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks-worker_attach" {
  role       = aws_iam_role.worker_role.name
  policy_arn = aws_iam_policy.worker_policy.arn
}
##################################################################################
# Management Security group
##################################################################################

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}