################################################################################
# Site to Site VPN
# https://github.com/terraform-aws-modules/terraform-aws-vpn-gateway
################################################################################
module "vpn_gateway" {
  source                = "terraform-aws-modules/vpn-gateway/aws"
  version               = "~> 3.0"
  create_vpn_connection = var.create_vpn_connection

  transit_gateway_id  = module.tgw[0].ec2_transit_gateway_id
  customer_gateway_id = module.vpc_security.cgw_ids[0]

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
    "10.100.30.69/32", "10.100.10.204/32", "10.100.10.210/32", "10.100.10.197/32", "10.100.10.198/32"
  ]

  tags = merge(
    local.tags,
    {
      Name = "vpn-${var.service}-${var.environment}-group"
    },
  )
}
