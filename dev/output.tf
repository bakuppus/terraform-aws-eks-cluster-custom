##################################################################################
## Cluster Output
##################################################################################
output "cluster_id" {
  value = module.eks.cluster_id
}

output "config_map_aws_auth" {
  value = module.eks.config_map_aws_auth
}

output "node_groups" {
  value = module.eks.node_groups
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
###################################################################################
# CloudWatch
###################################################################################

output "cloudwatch_log_group_name" {
  value = module.eks.cloudwatch_log_group_name
}

###################################################################################
#VPC Output
###################################################################################
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "availability_zones" {
  value = module.vpc.azs
}
output "private_subnets_id" {
  value = module.vpc.private_subnets
}

output "public_subnets_id" {
  value = module.vpc.public_subnets
}