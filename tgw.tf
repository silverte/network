################################################################################
# Transit Gateway Module
################################################################################

module "tgw" {
  source     = "terraform-aws-modules/transit-gateway/aws"
  version    = "~> 2.12"
  create_tgw = var.create_tgw
  count      = var.create_tgw ? 1 : 0

  name            = "tgw-${var.service}-${var.environment}"
  description     = "TGW shared with several other AWS accounts"
  amazon_side_asn = 64532

  transit_gateway_cidr_blocks = var.tgw_cidr_blocks

  # When "true" there is no need for RAM resources if using multiple AWS accounts
  enable_auto_accept_shared_attachments = false
  ram_allow_external_principals         = false
  share_tgw                             = false

  # When "true", allows service discovery through IGMP
  enable_multicast_support = false

  enable_default_route_table_association = false
  enable_default_route_table_propagation = false

  tgw_route_table_tags = merge(
    local.tags,
    {
      Name = "tgwrt-${var.service}-${var.environment}-hub"
    }
  )

  vpc_attachments = {
    vpc_security = {
      vpc_id       = module.vpc_security.vpc_id
      subnet_ids   = module.vpc_security.intra_subnets
      dns_support  = true
      ipv6_support = false
      tags = merge(
        local.tags,
        {
          Name = "tgwa-vpc-${var.service}-security"
        }
      )
    },
    vpc_dev = {
      vpc_id     = module.vpc_dev.vpc_id
      subnet_ids = module.vpc_dev.redshift_subnets
      tags = merge(
        local.tags,
        {
          Name = "tgwa-vpc-${var.service}-dev"
        }
      )
    },
    vpc_shared = {
      vpc_id     = module.vpc_shared.vpc_id
      subnet_ids = module.vpc_shared.redshift_subnets
      tags = merge(
        local.tags,
        {
          Name = "tgwa-vpc-${var.service}-shared"
        }
      )
    },
    # vpc_sandbox = {
    #   vpc_id     = module.vpc_sandbox.vpc_id
    #   subnet_ids = module.vpc_sandbox.redshift_subnets
    #   tags = merge(
    #     local.tags,
    #     {
    #       Name = "tgwa-vpc-${var.service}-sandbox"
    #     }
    #   )
    # },
    # vpc_prd = {
    #   vpc_id     = module.vpc_prd.vpc_id
    #   subnet_ids = module.vpc_prd.redshift_subnets
    #   tags = merge(
    #     local.tags,
    #     {
    #       Name = "tgwa-vpc-${var.service}-prd"
    #     }
    #   )
    # },
    # vpc_stg = {
    #   vpc_id     = module.vpc_stg.vpc_id
    #   subnet_ids = module.vpc_stg.redshift_subnets
    #   tags = merge(
    #     local.tags,
    #     {
    #       Name = "tgwa-vpc-${var.service}-stg"
    #     }
    #   )
    # },
  }

  tags = merge(
    local.tags,
    {
      Name = "tgw-${var.service}-${var.environment}"
    }
  )
}

# # hub route table association
# resource "aws_ec2_transit_gateway_route_table_association" "hub" {
#   depends_on                     = [module.tgw]
#   transit_gateway_attachment_id  = module.tgw[0].ec2_transit_gateway_vpc_attachment["vpc_security"].id
#   transit_gateway_route_table_id = module.tgw[0].ec2_transit_gateway_route_table_id
# }

# # hub add route
# resource "aws_ec2_transit_gateway_route" "hub_route_dev" {
#   depends_on                     = [module.tgw]
#   destination_cidr_block         = "10.222.0.0/16"
#   transit_gateway_attachment_id  = module.tgw[0].ec2_transit_gateway_vpc_attachment["vpc_dev"].id
#   transit_gateway_route_table_id = module.tgw[0].ec2_transit_gateway_route_table_id
# }

# resource "aws_ec2_transit_gateway_route" "hub_route_sandbox" {
#   depends_on                     = [module.tgw]
#   destination_cidr_block         = "10.221.0.0/16"
#   transit_gateway_attachment_id  = module.tgw[0].ec2_transit_gateway_vpc_attachment["vpc_security"].id
#   transit_gateway_route_table_id = module.tgw[0].ec2_transit_gateway_route_table_id
# }

# # spoke route table
# resource "aws_ec2_transit_gateway_route_table" "spoke" {
#   depends_on         = [module.tgw]
#   transit_gateway_id = module.tgw[0].ec2_transit_gateway_id

#   tags = merge(
#     local.tags,
#     {
#       Name = "tgwrt-${var.service}-${var.environment}-spoke"
#     }
#   )
# }

# # spoke route table association
# resource "aws_ec2_transit_gateway_route_table_association" "spoke_dev" {
#   depends_on                     = [module.tgw]
#   transit_gateway_attachment_id  = module.tgw[0].ec2_transit_gateway_vpc_attachment["vpc_dev"].id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
# }

# resource "aws_ec2_transit_gateway_route_table_association" "spoke_sandbox" {
#   depends_on                     = [module.tgw]
#   transit_gateway_attachment_id  = module.tgw[0].ec2_transit_gateway_vpc_attachment["vpc_shared"].id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
# }

# # spoke add route
# resource "aws_ec2_transit_gateway_route" "spoke_route" {
#   depends_on                     = [module.tgw]
#   destination_cidr_block         = "10.223.0.0/16"
#   transit_gateway_attachment_id  = module.tgw[0].ec2_transit_gateway_vpc_attachment["vpc_security"].id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
# }
