# Whether to Create DX Connection
variable "create_dx_connection" {
  type    = bool
  default = true
}

# Whether to Create DX Gateway Association
variable "create_dx_gateway_association" {
  type    = bool
  default = true
}

# Whether to Create DX Gateway
variable "create_dx_gateway" {
  type    = bool
  default = false
}

# Whether to Create DX Transit Virtual Interface
variable "create_dx_transit_virtual_interface" {
  type    = bool
  default = false
}
