################################################################################
# VPC Module
# reference: https://github.com/terraform-aws-modules/terraform-aws-vpc
################################################################################
module "vpc_stg" {
  source     = "terraform-aws-modules/vpc/aws"
  version    = "5.13.0"
  create_vpc = var.create_vpc_stg

  # Details
  name                = "vpc-${var.service}-stg"
  cidr                = var.cidr_stg
  azs                 = local.azs
  private_subnets     = var.app_subnets_stg
  intra_subnets       = var.endpoint_subnets_stg
  database_subnets    = var.database_subnets_stg
  elasticache_subnets = var.elb_subnets_stg
  redshift_subnets    = var.tgw_attach_subnets_stg

  manage_default_route_table    = false
  manage_default_network_acl    = false
  manage_default_security_group = false
  manage_default_vpc            = false

  # don't create Subnet Group 
  create_database_subnet_group    = false
  create_elasticache_subnet_group = false
  create_redshift_subnet_group    = false

  # Tag subnets
  private_subnet_names     = ["sub-${var.service}-stg-app-a", "sub-${var.service}-stg-app-c"]
  database_subnet_names    = ["sub-${var.service}-stg-db-a", "sub-${var.service}-stg-db-c"]
  intra_subnet_names       = ["sub-${var.service}-stg-ep-a", "sub-${var.service}-stg-ep-c"]
  elasticache_subnet_names = ["sub-${var.service}-stg-elb-a", "sub-${var.service}-stg-elb-c"]
  redshift_subnet_names    = ["sub-${var.service}-stg-tgw-a", "sub-${var.service}-stg-tgw-c"]

  # Routing
  create_database_subnet_route_table    = true
  create_elasticache_subnet_route_table = true
  create_redshift_subnet_route_table    = true

  # Tag route table
  private_route_table_tags     = { "Name" : "route-${var.service}-stg-app" }
  database_route_table_tags    = { "Name" : "route-${var.service}-stg-db" }
  intra_route_table_tags       = { "Name" : "route-${var.service}-stg-ep" }
  elasticache_route_table_tags = { "Name" : "route-${var.service}-stg-elb" }
  redshift_route_table_tags    = { "Name" : "route-${var.service}-stg-tgw" }

  igw_tags = { "Name" : "igw-${var.service}-stg" }

  # NAT Gateways - Outbound Communication
  enable_nat_gateway = var.enable_nat_gateway_stg
  single_nat_gateway = var.single_nat_gateway_stg
  nat_gateway_tags   = { "Name" : "nat-${var.service}-stg" }
  nat_eip_tags       = { "Name" : "eip-${var.service}-stg" }

  # DNS Parameters in VPC
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Flow logs
  enable_flow_log                                 = var.enable_vpc_flow_log_stg
  flow_log_destination_type                       = "s3"
  flow_log_destination_arn                        = var.vpc_flow_log_s3_arn_stg
  flow_log_file_format                            = "plain-text"
  flow_log_log_format                             = "$${version} $${vpc-id} $${subnet-id} $${instance-id} $${interface-id} $${account-id} $${type} $${srcaddr} $${dstport} $${srcport} $${dstaddr} $${pkt-dstaddr} $${pkt-srcaddr} $${protocol} $${bytes} $${packets} $${start} $${end} $${action} $${tcp-flags} $${log-status}"
  flow_log_max_aggregation_interval               = 600
  vpc_flow_log_iam_role_name                      = "role-${var.service}-stg-vpc-flow-log"
  vpc_flow_log_iam_role_use_name_prefix           = false
  create_flow_log_cloudwatch_log_group            = true
  create_flow_log_cloudwatch_iam_role             = true
  flow_log_cloudwatch_log_group_retention_in_days = 7
  flow_log_cloudwatch_log_group_name_prefix       = "vpcFlowLog"
  flow_log_cloudwatch_log_group_skip_destroy      = true
  flow_log_traffic_type                           = "ALL"
  flow_log_per_hour_partition                     = true

  vpc_flow_log_tags = merge(
    local.tags,
    {
      "Name" = "vpc-${var.service}-stg-flow-logs"
    }
  )

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = "eks-${var.service}-stg"
  }

  # tags for the VPC
  tags = merge(
    local.tags,
    {
      "environment" = "stg"
    }
  )
}

# S3 Bucket
# module "s3_bucket" {
#   source  = "terraform-aws-modules/s3-bucket/aws"
#   version = "~> 3.0"

#   bucket        = local.s3_bucket_name
#   policy        = data.aws_iam_policy_document.flow_log_s3.json
#   force_destroy = true

#   tags = local.tags
# }

# data "aws_iam_policy_document" "flow_log_s3" {
#   statement {
#     sid = "AWSLogDeliveryWrite"

#     principals {
#       type        = "Service"
#       identifiers = ["delivery.logs.amazonaws.com"]
#     }

#     actions = ["s3:PutObject"]

#     resources = ["arn:aws:s3:::${local.s3_bucket_name}/AWSLogs/*"]
#   }

#   statement {
#     sid = "AWSLogDeliveryAclCheck"

#     principals {
#       type        = "Service"
#       identifiers = ["delivery.logs.amazonaws.com"]
#     }

#     actions = ["s3:GetBucketAcl"]

#     resources = ["arn:aws:s3:::${local.s3_bucket_name}"]
#   }
# }

# Fully private cluster only
module "vpc_endpoints_stg" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.13.0"
  create  = var.create_vpc_stg

  vpc_id = module.vpc_stg.vpc_id

  # Security group
  create_security_group      = true
  security_group_name        = "scg-${var.service}-stg-endpoint"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [module.vpc_stg.vpc_cidr_block]
    }
  }
  security_group_tags = merge(
    local.tags,
    { "Name" = "scg-${var.service}-stg-endpoint"
  })

  endpoints = merge({
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc_stg.private_route_table_ids
      tags = merge(
        local.tags,
      { "Name" = "ep-${var.service}-stg-gw-s3" })
    }
    },
    #   { for service in toset(["autoscaling", "ecr.api", "ecr.dkr", "ec2", "ec2messages", "elasticloadbalancing", "sts", "kms", "logs", "ssm", "ssmmessages"]) :
    #     replace(service, ".", "_") =>
    #     {
    #       service             = service
    #       subnet_ids          = module.vpc.infra_subnets
    #       private_dns_enabled = true
    #       tags = merge(
    #         local.tags,
    #       { Name = "$ep-${var.service}-${var.environment}-${service}" })
    #     }
    # }
  )
}
