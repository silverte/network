################################################################################
# Transit Gateway Module
################################################################################

module "tgw" {
  source     = "terraform-aws-modules/transit-gateway/aws"
  version    = "~> 2.12"
  create_tgw = var.create_tgw
  count      = var.create_tgw ? 1 : 0

  name            = "tgw-${var.service}"
  description     = "TGW shared with several other AWS accounts"
  amazon_side_asn = 64532

  transit_gateway_cidr_blocks = var.tgw_cidr_blocks

  # When "true" there is no need for RAM resources if using multiple AWS accounts
  enable_auto_accept_shared_attachments = true

  # When "true", allows service discovery through IGMP
  enable_multicast_support = false

  enable_default_route_table_association = false
  enable_default_route_table_propagation = false

  vpc_attachments = {
    vpc_network = {
      vpc_id       = module.vpc_network.vpc_id
      subnet_ids   = module.vpc_network.redshift_subnets
      dns_support  = true
      ipv6_support = false

      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false

      tgw_routes = [
        {
          destination_cidr_block = "10.223.0.0/16"
        },
        {
          blackhole              = true
          destination_cidr_block = "0.0.0.0/0"
        }
      ]
      tags = merge(
        local.tags,
        {
          Name = "tgwa-${var.service}-network"
        }
      )
    },
    vpc_dev = {
      vpc_id     = module.vpc_dev.vpc_id
      subnet_ids = module.vpc_dev.redshift_subnets

      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false

      tgw_routes = [
        {
          destination_cidr_block = "10.222.0.0/16"
        }
      ]
      tags = merge(
        local.tags,
        {
          Name = "tgwa-${var.service}-dev"
        }
      )
    },
    vpc_sandbox = {
      vpc_id     = module.vpc_sandbox.vpc_id
      subnet_ids = module.vpc_sandbox.redshift_subnets

      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false

      tgw_routes = [
        {
          destination_cidr_block = "10.221.0.0/16"
        }
      ]
      tags = merge(
        local.tags,
        {
          Name = "tgwa-${var.service}-sandbox"
        }
      )
    },
  }

  #   ram_allow_external_principals = true
  #   ram_principals                = [307990089504]

  tags = merge(
    local.tags,
    {
      Name = "tgw-${var.service}"
    }
  )
}
