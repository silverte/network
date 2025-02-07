##################################################################
# Common Prefix List
##################################################################
# Whether to create an Prefix lists (True or False)
variable "create_prefix_lists" {
  description = "Whether to create prefix lists"
  type        = bool
  default     = false
}

# prefix lists Office
variable "office_ip_ips" {
  description = "List of Office ips"
  type        = list(string)
  default     = []
}

# prefix lists DBSafer
variable "dbsafer_ips" {
  description = "List of DBSafer ips"
  type        = list(string)
  default     = []
}

##################################################################
# Dev Subnet Prefix List
##################################################################
variable "dev_app_subnet_pod_ips" {
  description = "List of App subent pod ips"
  type        = list(string)
  default     = []
}
variable "dev_app_subnet_vm_ips" {
  description = "List of App subent vm ips"
  type        = list(string)
  default     = []
}
variable "dev_db_subnet_ips" {
  description = "List of DB subent ips"
  type        = list(string)
  default     = []
}
variable "dev_elb_subnet_ips" {
  description = "List of ELB subent ips"
  type        = list(string)
  default     = []
}

##################################################################
# Stg Subnet Prefix List
##################################################################
variable "stg_app_subnet_pod_ips" {
  description = "List of App subent pod ips"
  type        = list(string)
  default     = []
}
variable "stg_app_subnet_vm_ips" {
  description = "List of App subent vm ips"
  type        = list(string)
  default     = []
}
variable "stg_db_subnet_ips" {
  description = "List of DB subent ips"
  type        = list(string)
  default     = []
}
variable "stg_elb_subnet_ips" {
  description = "List of ELB subent ips"
  type        = list(string)
  default     = []
}

##################################################################
# Prd Subnet Prefix List
##################################################################
variable "prd_app_subnet_pod_ips" {
  description = "List of App subent pod ips"
  type        = list(string)
  default     = []
}
variable "prd_app_subnet_vm_ips" {
  description = "List of App subent vm ips"
  type        = list(string)
  default     = []
}
variable "prd_db_subnet_ips" {
  description = "List of DB subent ips"
  type        = list(string)
  default     = []
}
variable "prd_elb_subnet_ips" {
  description = "List of ELB subent ips"
  type        = list(string)
  default     = []
}

##################################################################
# Shared Subnet Prefix List
##################################################################
variable "shared_app_subnet_pod_ips" {
  description = "List of App subent pod ips"
  type        = list(string)
  default     = []
}
variable "shared_app_subnet_vm_ips" {
  description = "List of App subent vm ips"
  type        = list(string)
  default     = []
}
variable "shared_db_subnet_ips" {
  description = "List of DB subent ips"
  type        = list(string)
  default     = []
}
variable "shared_elb_subnet_ips" {
  description = "List of ELB subent ips"
  type        = list(string)
  default     = []
}
