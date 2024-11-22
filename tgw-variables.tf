# Whether to create Transit gateway
variable "create_tgw" {
  description = "Whether to create Transit gateway"
  type        = bool
  default     = false
}

# Trangit gateway CIDR Blocks
variable "tgw_cidr_blocks" {
  description = "Trangit gateway CIDR Blocks"
  type        = list(string)
  default     = []
}
