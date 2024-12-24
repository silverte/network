################################################################################
# Site to Site VPN
# https://github.com/terraform-aws-modules/terraform-aws-vpn-gateway
################################################################################
module "vpn_gateway_group" {
  source                = "terraform-aws-modules/vpn-gateway/aws"
  version               = "~> 3.0"
  create_vpn_connection = var.create_vpn_connection

  transit_gateway_id  = module.tgw[0].ec2_transit_gateway_id
  customer_gateway_id = aws_customer_gateway.customer_gateway_group.id

  tunnel_inside_ip_version = "ipv4"
  # tunnel inside cidr & preshared keys (optional)
  # tunnel1_inside_cidr   = "169.254.44.88/30"
  # tunnel2_inside_cidr   = "169.254.44.100/30"
  # tunnel1_preshared_key = "1234567890abcdefghijklmn"
  # tunnel2_preshared_key = "abcdefghijklmn1234567890"

  create_vpn_gateway_attachment = false
  connect_to_transit_gateway    = true

  # Static routes for remote network
  vpn_connection_static_routes_only         = true
  vpn_connection_static_routes_destinations = var.vpn_connection_static_routes

  tags = merge(
    local.tags,
    {
      Name = "vpn-${var.service}-${var.environment}-group"
    },
  )
}

resource "aws_customer_gateway" "customer_gateway_group" {
  bgp_asn    = var.customer_gateway_bgp_asn
  ip_address = var.customer_gateway_static_public_ip
  type       = "ipsec.1"
  tags = merge(
    local.tags,
    {
      Name = "cgw-${var.service}-${var.environment}-group"
    },
  )
}

# VPN Gateway Attachment for Office - Temporary
module "vpn_gateway" {
  source                = "terraform-aws-modules/vpn-gateway/aws"
  version               = "~> 3.0"
  create_vpn_connection = var.create_vpn_connection

  transit_gateway_id  = module.tgw[0].ec2_transit_gateway_id
  customer_gateway_id = aws_customer_gateway.customer_gateway_office[0].id

  tunnel_inside_ip_version = "ipv4"
  # tunnel inside cidr & preshared keys (optional)
  # tunnel1_inside_cidr   = "169.254.44.88/30"
  # tunnel2_inside_cidr   = "169.254.44.100/30"
  # tunnel1_preshared_key = "1234567890abcdefghijklmn"
  # tunnel2_preshared_key = "abcdefghijklmn1234567890"

  create_vpn_gateway_attachment = false
  connect_to_transit_gateway    = true

  # Static routes for remote network
  vpn_connection_static_routes_only = true
  vpn_connection_static_routes_destinations = [
    "10.65.10.0/24", "10.65.20.0/24", "10.65.30.0/24"
  ]

  tags = merge(
    local.tags,
    {
      Name = "vpn-${var.service}-${var.environment}-office"
    },
  )
}

resource "aws_customer_gateway" "customer_gateway_office" {
  count      = var.create_vpn_connection ? 1 : 0
  bgp_asn    = "65000"
  ip_address = "59.6.169.100"
  type       = "ipsec.1"

  tags = merge(
    local.tags,
    {
      Name = "cgw-${var.service}-${var.environment}-office"
    },
  )
}
