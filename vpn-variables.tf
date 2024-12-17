# Whether to create VPN Connection
variable "create_vpn_connection" {
  description = "Whether to create VPN Connection"
  type        = bool
  default     = false
}

# Customer Gateway Public IP Variable
variable "customer_gateway_static_public_ip" {
  type    = string
  default = ""
}

# Customer Gateway BGP ASN Variable
variable "customer_gateway_bgp_asn" {
  type    = number
  default = 65000
}

# VPN Static route CIDRs Variable
variable "vpn_connection_static_routes" {
  type    = list(string)
  default = []
}
