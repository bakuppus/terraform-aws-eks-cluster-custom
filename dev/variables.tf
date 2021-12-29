##################################################################################
# VARIABLES
##################################################################################
variable "profile" {
  type        = string
  description = "AWS profile to use"
  default = "kubelancer-sandbox-account"
}

variable "region" {
  type        = string
  description = "Aws region to use"
  default = "us-west-2"
}


variable "cluster_name" {
  description = "AWS EKS cluster name needed for Shared cluster"
  type        = string
  default     = "custom-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
  default     = "1.19"
}


variable "environment" {
  type = string
  description = "Environment to use"
  default = "dev"
}

variable "owner" {
  type = string
  description = "owner of environment"
  default = "kubelancer"
  }

variable "is_terraform" {
  type = bool
  description = "Maintain by terraform ..."
  default = true
}

variable "vpc_name" {
  description = "Name of VPC to be used on all the resources as identifier"
  type        = string
  default = "dev-vpc"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "Assigns IPv4 private subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "Assigns IPv4 public subnet id based on the Amazon provided /56 prefix base 10 integer (0-256). Must be of equal length to the corresponding IPv4 subnet list"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}