################################################################################
# VPC Module
# reference: https://github.com/terraform-aws-modules/terraform-aws-vpc
################################################################################
module "vpc_security" {
  source     = "terraform-aws-modules/vpc/aws"
  version    = "5.13.0"
  create_vpc = var.create_vpc_security

  # Details
  name             = "vpc-${var.service}-security"
  cidr             = var.cidr_security
  azs              = local.azs
  public_subnets   = var.public_subnets_security
  private_subnets  = var.app_subnets_security
  intra_subnets    = var.endpoint_subnets_security
  database_subnets = var.waf_subnets_security
  redshift_subnets = var.tgw_attach_subnets_security

  manage_default_route_table    = false
  manage_default_network_acl    = false
  manage_default_security_group = false
  manage_default_vpc            = false

  # don't create Subnet Group 
  create_database_subnet_group    = false
  create_elasticache_subnet_group = false
  create_redshift_subnet_group    = false

  # Tag subnets
  public_subnet_names   = ["sub-${var.service}-security-pub-a", "sub-${var.service}-security-pub-c"]
  private_subnet_names  = ["sub-${var.service}-security-app-a", "sub-${var.service}-security-app-c"]
  database_subnet_names = ["sub-${var.service}-security-waf-a", "sub-${var.service}-security-waf-c"]
  intra_subnet_names    = ["sub-${var.service}-security-ep-a", "sub-${var.service}-security-ep-c"]
  redshift_subnet_names = ["sub-${var.service}-security-tgw-a", "sub-${var.service}-security-tgw-c"]

  # Routing
  create_database_subnet_route_table  = true
  create_redshift_subnet_route_table  = true
  create_multiple_public_route_tables = true

  # Tag route table
  public_route_table_tags   = { "Name" : "route-${var.service}-security-pub" }
  private_route_table_tags  = { "Name" : "route-${var.service}-security-app" }
  database_route_table_tags = { "Name" : "route-${var.service}-security-waf" }
  intra_route_table_tags    = { "Name" : "route-${var.service}-security-ep" }
  redshift_route_table_tags = { "Name" : "route-${var.service}-security-tgw" }

  igw_tags = { "Name" : "igw-${var.service}-security" }

  # NAT Gateways - Outbound Communication
  enable_nat_gateway = var.enable_nat_gateway_security
  single_nat_gateway = var.single_nat_gateway_security
  nat_gateway_tags   = { "Name" : "nat-${var.service}-security" }
  nat_eip_tags       = { "Name" : "eip-${var.service}-security" }

  # DNS Parameters in VPC
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Flow logs
  enable_flow_log                         = var.enable_vpc_flow_log_security
  flow_log_destination_type               = "s3"
  flow_log_destination_arn                = var.vpc_flow_log_s3_arn_security
  flow_log_file_format                    = "plain-text"
  flow_log_log_format                     = "$${version} $${vpc-id} $${subnet-id} $${instance-id} $${interface-id} $${account-id} $${type} $${srcaddr} $${dstport} $${srcport} $${dstaddr} $${pkt-dstaddr} $${pkt-srcaddr} $${protocol} $${bytes} $${packets} $${start} $${end} $${action} $${tcp-flags} $${log-status}"
  flow_log_max_aggregation_interval       = 600
  vpc_flow_log_iam_role_name              = "role-${var.service}-security-vpc-flow-log"
  vpc_flow_log_iam_role_use_name_prefix   = false
  vpc_flow_log_iam_policy_name            = "policy-${var.service}-security-vpc-flow-log"
  vpc_flow_log_iam_policy_use_name_prefix = false
  # create_flow_log_cloudwatch_log_group            = true
  # create_flow_log_cloudwatch_iam_role             = true
  # flow_log_cloudwatch_log_group_retention_in_days = 7
  # flow_log_cloudwatch_log_group_name_prefix       = "vpcFlowLog"
  # flow_log_cloudwatch_log_group_skip_destroy      = true
  flow_log_traffic_type       = "ALL"
  flow_log_per_hour_partition = true

  vpc_flow_log_tags = merge(
    local.tags,
    {
      "Name" = "vpc-${var.service}-security-flow-logs"
    }
  )

  # tags for the VPC
  tags = merge(
    local.tags,
    {
      "environment" = "security"
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
module "vpc_endpoints_security" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.13.0"
  create  = var.create_vpc_security

  vpc_id = module.vpc_security.vpc_id

  # Security group
  create_security_group      = true
  security_group_name        = "scg-${var.service}-security-endpoint"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [module.vpc_security.vpc_cidr_block]
    }
  }
  security_group_tags = merge(
    local.tags,
    { "Name" = "scg-${var.service}-security-endpoint"
  })

  endpoints = merge({
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc_security.private_route_table_ids
      tags = merge(
        local.tags,
      { "Name" = "ep-${var.service}-security-gw-s3" })
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
