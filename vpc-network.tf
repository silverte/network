################################################################################
# VPC Module
# reference: https://github.com/terraform-aws-modules/terraform-aws-vpc
################################################################################
module "vpc_network" {
  source     = "terraform-aws-modules/vpc/aws"
  version    = "5.13.0"
  create_vpc = var.enable_vpc_network

  # Details
  name                = "vpc-${var.service}-network"
  cidr                = var.cidr_network
  azs                 = local.azs
  public_subnets      = var.public_subnets_network
  private_subnets     = var.private_subnets_network
  intra_subnets       = var.endpoint_subnets_network
  database_subnets    = var.database_subnets_network
  elasticache_subnets = var.elb_subnets_network
  redshift_subnets    = var.tgw_attach_subnets_network

  manage_default_route_table    = false
  manage_default_network_acl    = false
  manage_default_security_group = false
  manage_default_vpc            = false

  # don't create Subnet Group 
  create_database_subnet_group    = false
  create_elasticache_subnet_group = false
  create_redshift_subnet_group    = false

  # Tag subnets
  public_subnet_names      = ["sub-${var.service}-network-pub-a", "sub-${var.service}-network-pub-c"]
  private_subnet_names     = ["sub-${var.service}-network-pri-a", "sub-${var.service}-network-pri-c"]
  database_subnet_names    = ["sub-${var.service}-network-db-a", "sub-${var.service}-network-db-c"]
  intra_subnet_names       = ["sub-${var.service}-network-ep-a", "sub-${var.service}-network-ep-c"]
  elasticache_subnet_names = ["sub-${var.service}-network-elb-a", "sub-${var.service}-network-elb-c"]
  redshift_subnet_names    = ["sub-${var.service}-network-tgw-a", "sub-${var.service}-network-tgw-c"]

  # Routing
  create_database_subnet_route_table    = true
  create_elasticache_subnet_route_table = true
  create_redshift_subnet_route_table    = true

  # Tag route table
  public_route_table_tags      = { "Name" : "route-${var.service}-network-pub" }
  private_route_table_tags     = { "Name" : "route-${var.service}-network-pri" }
  database_route_table_tags    = { "Name" : "route-${var.service}-network-db" }
  intra_route_table_tags       = { "Name" : "route-${var.service}-network-ep" }
  elasticache_route_table_tags = { "Name" : "route-${var.service}-network-elb" }
  redshift_route_table_tags    = { "Name" : "route-${var.service}-network-tgw" }

  igw_tags = { "Name" : "igw-${var.service}-network" }

  # NAT Gateways - Outbound Communication
  enable_nat_gateway = var.enable_nat_gateway_network
  single_nat_gateway = var.single_nat_gateway_network
  nat_gateway_tags   = { "Name" : "nat-${var.service}-network" }
  nat_eip_tags       = { "Name" : "eip-${var.service}-network" }

  # DNS Parameters in VPC
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Flow logs
  enable_flow_log                       = var.enable_vpc_flow_log_network
  flow_log_destination_type             = "s3"
  flow_log_destination_arn              = var.vpc_flow_log_s3_arn_network
  flow_log_max_aggregation_interval     = 600
  vpc_flow_log_iam_role_name            = "role-${var.service}-network-vpc-flow-log"
  vpc_flow_log_iam_role_use_name_prefix = false
  create_flow_log_cloudwatch_log_group  = true
  create_flow_log_cloudwatch_iam_role   = true

  vpc_flow_log_tags = merge(
    local.tags,
    {
      "Name" = "vpc-${var.service}-network-flow-logs"
    }
  )

  # public_subnet_tags = {
  #   "kubernetes.io/role/elb" = 1
  # }

  # private_subnet_tags = {
  #   "kubernetes.io/role/internal-elb" = 1
  #   # Tags subnets for Karpenter auto-discovery
  #   "karpenter.sh/discovery" = "eks-${var.service}-network"
  # }

  # tags for the VPC
  tags = {
    owners      = local.owners
    environment = "network"
    service     = local.service
  }
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
module "vpc_endpoints_network" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.13.0"
  create  = var.enable_vpc_network

  vpc_id = module.vpc_network.vpc_id

  # Security group
  create_security_group      = true
  security_group_name        = "scg-${var.service}-network-endpoint"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [module.vpc_network.vpc_cidr_block]
    }
  }
  security_group_tags = merge(
    local.tags,
    { "Name" = "scg-${var.service}-network-endpoint"
  })

  endpoints = merge({
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc_network.private_route_table_ids
      tags = merge(
        local.tags,
      { "Name" = "ep-${var.service}-network-gw-s3" })
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
