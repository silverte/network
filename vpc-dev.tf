################################################################################
# VPC Module
# reference: https://github.com/terraform-aws-modules/terraform-aws-vpc
################################################################################
module "vpc_dev" {
  source     = "terraform-aws-modules/vpc/aws"
  version    = "5.13.0"
  create_vpc = var.create_vpc_dev

  # Details
  name                = "vpc-${var.service}-dev"
  cidr                = var.cidr_dev
  azs                 = local.azs
  private_subnets     = var.app_subnets_dev
  intra_subnets       = var.endpoint_subnets_dev
  database_subnets    = var.database_subnets_dev
  elasticache_subnets = var.elb_subnets_dev
  redshift_subnets    = var.tgw_attach_subnets_dev

  manage_default_route_table    = false
  manage_default_network_acl    = false
  manage_default_security_group = false
  manage_default_vpc            = false

  # don't create Subnet Group 
  create_database_subnet_group    = false
  create_elasticache_subnet_group = false
  create_redshift_subnet_group    = false

  # Tag subnets
  private_subnet_names     = ["sub-${var.service}-dev-app-a", "sub-${var.service}-dev-app-c"]
  database_subnet_names    = ["sub-${var.service}-dev-db-a", "sub-${var.service}-dev-db-c"]
  intra_subnet_names       = ["sub-${var.service}-dev-ep-a", "sub-${var.service}-dev-ep-c"]
  elasticache_subnet_names = ["sub-${var.service}-dev-elb-a", "sub-${var.service}-dev-elb-c"]
  redshift_subnet_names    = ["sub-${var.service}-dev-tgw-a", "sub-${var.service}-dev-tgw-c"]

  # Routing
  create_database_subnet_route_table    = true
  create_elasticache_subnet_route_table = true
  create_redshift_subnet_route_table    = true

  # Tag route table
  private_route_table_tags     = { "Name" : "route-${var.service}-dev-app" }
  database_route_table_tags    = { "Name" : "route-${var.service}-dev-db" }
  intra_route_table_tags       = { "Name" : "route-${var.service}-dev-ep" }
  elasticache_route_table_tags = { "Name" : "route-${var.service}-dev-elb" }
  redshift_route_table_tags    = { "Name" : "route-${var.service}-dev-tgw" }

  igw_tags = { "Name" : "igw-${var.service}-dev" }

  # NAT Gateways - Outbound Communication
  enable_nat_gateway = var.enable_nat_gateway_dev
  single_nat_gateway = var.single_nat_gateway_dev
  nat_gateway_tags   = { "Name" : "nat-${var.service}-dev" }
  nat_eip_tags       = { "Name" : "eip-${var.service}-dev" }

  # DNS Parameters in VPC
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Flow logs
  enable_flow_log                       = var.enable_vpc_flow_log_dev
  flow_log_destination_type             = "s3"
  flow_log_destination_arn              = var.vpc_flow_log_s3_arn_dev
  flow_log_max_aggregation_interval     = 600
  vpc_flow_log_iam_role_name            = "role-${var.service}-dev-vpc-flow-log"
  vpc_flow_log_iam_role_use_name_prefix = false
  create_flow_log_cloudwatch_log_group  = true
  create_flow_log_cloudwatch_iam_role   = true

  vpc_flow_log_tags = merge(
    local.tags,
    {
      "Name" = "vpc-${var.service}-dev-flow-logs"
    }
  )

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    # Tags subnets for Karpenter auto-discovery
    "karpenter.sh/discovery" = "eks-${var.service}-dev"
  }

  # tags for the VPC
  tags = {
    owners      = local.owners
    environment = "dev"
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
module "vpc_endpoints_dev" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.13.0"
  create  = var.create_vpc_dev

  vpc_id = module.vpc_dev.vpc_id

  # Security group
  create_security_group      = true
  security_group_name        = "scg-${var.service}-dev-endpoint"
  security_group_description = "VPC endpoint security group"
  security_group_rules = {
    ingress_https = {
      description = "HTTPS from VPC"
      cidr_blocks = [module.vpc_dev.vpc_cidr_block]
    }
  }
  security_group_tags = merge(
    local.tags,
    { "Name" = "scg-${var.service}-dev-endpoint"
  })

  endpoints = merge({
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc_dev.private_route_table_ids
      tags = merge(
        local.tags,
      { "Name" = "ep-${var.service}-dev-gw-s3" })
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
