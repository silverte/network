
##################################################################
# Common Prefix List
##################################################################
resource "aws_ec2_managed_prefix_list" "prx_esp_office_ip" {
  count          = var.create_prefix_lists ? 1 : 0
  name           = "prx-${var.service}-office-ip"
  address_family = "IPv4"
  max_entries    = length(var.office_ip_ips)

  dynamic "entry" {
    for_each = var.office_ip_ips
    content {
      cidr        = entry.value
      description = "office #${entry.key + 1}"
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "prx-${var.service}-office-ip",
    }
  )
}


resource "aws_ec2_managed_prefix_list" "prx_esp_dbsafer_ip" {
  count          = var.create_prefix_lists ? 1 : 0
  name           = "prx-${var.service}-dbsafer-ip"
  address_family = "IPv4"
  max_entries    = length(var.dbsafer_ips)

  dynamic "entry" {
    for_each = var.dbsafer_ips
    content {
      cidr        = entry.value
      description = "dbsafer #${entry.key + 1}"
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "prx-${var.service}-dbsafer-ip",
    }
  )
}

##################################################################
# Dev Subnet Prefix List
##################################################################
resource "aws_ec2_managed_prefix_list" "pl_esp_sub_app_pod_ip" {
  count          = var.create_prefix_lists ? 1 : 0
  name           = "pl-${var.service}-dev-sub-app-pod-ip"
  address_family = "IPv4"
  max_entries    = length(var.dev_app_subnet_pod_ips)

  dynamic "entry" {
    for_each = var.dev_app_subnet_pod_ips
    content {
      cidr        = entry.value
      description = "app subnet pod #${entry.key + 1}"
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "pl-${var.service}-dev-sub-app-pod-ip",
    }
  )
}

resource "aws_ec2_managed_prefix_list" "pl_esp_sub_app_vm_ip" {
  count          = var.create_prefix_lists ? 1 : 0
  name           = "pl-${var.service}-dev-sub-app-vm-ip"
  address_family = "IPv4"
  max_entries    = length(var.dev_app_subnet_vm_ips)

  dynamic "entry" {
    for_each = var.dev_app_subnet_vm_ips
    content {
      cidr        = entry.value
      description = "app subnet vm #${entry.key + 1}"
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "pl-${var.service}-dev-sub-app-vm-ip",
    }
  )
}

resource "aws_ec2_managed_prefix_list" "pl_esp_sub_db_vm_ip" {
  count          = var.create_prefix_lists ? 1 : 0
  name           = "pl-${var.service}-dev-sub-db-ip"
  address_family = "IPv4"
  max_entries    = length(var.dev_db_subnet_ips)

  dynamic "entry" {
    for_each = var.dev_db_subnet_ips
    content {
      cidr        = entry.value
      description = "db subnet #${entry.key + 1}"
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "pl-${var.service}-dev-sub-db-ip",
    }
  )
}

resource "aws_ec2_managed_prefix_list" "pl_esp_sub_elb_ip" {
  count          = var.create_prefix_lists ? 1 : 0
  name           = "pl-${var.service}-dev-sub-elb-ip"
  address_family = "IPv4"
  max_entries    = length(var.dev_elb_subnet_ips)

  dynamic "entry" {
    for_each = var.dev_elb_subnet_ips
    content {
      cidr        = entry.value
      description = "elb subnet #${entry.key + 1}"
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "pl-${var.service}-dev-sub-elb-ip",
    }
  )
}

##################################################################
# Stg Subnet Prefix List
##################################################################
resource "aws_ec2_managed_prefix_list" "pl_esp_sub_stg_app_pod_ip" {
  count          = var.create_prefix_lists ? 1 : 0
  name           = "pl-${var.service}-stg-sub-app-pod-ip"
  address_family = "IPv4"
  max_entries    = length(var.stg_app_subnet_pod_ips)

  dynamic "entry" {
    for_each = var.stg_app_subnet_pod_ips
    content {
      cidr        = entry.value
      description = "app subnet pod #${entry.key + 1}"
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "pl-${var.service}-stg-sub-app-pod-ip",
    }
  )
}

resource "aws_ec2_managed_prefix_list" "pl_esp_sub_stg_app_vm_ip" {
  count          = var.create_prefix_lists ? 1 : 0
  name           = "pl-${var.service}-stg-sub-app-vm-ip"
  address_family = "IPv4"
  max_entries    = length(var.stg_app_subnet_vm_ips)

  dynamic "entry" {
    for_each = var.stg_app_subnet_vm_ips
    content {
      cidr        = entry.value
      description = "app subnet vm #${entry.key + 1}"
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "pl-${var.service}-stg-sub-app-vm-ip",
    }
  )
}

resource "aws_ec2_managed_prefix_list" "pl_esp_sub_stg_db_vm_ip" {
  count          = var.create_prefix_lists ? 1 : 0
  name           = "pl-${var.service}-stg-sub-db-ip"
  address_family = "IPv4"
  max_entries    = length(var.stg_db_subnet_ips)

  dynamic "entry" {
    for_each = var.stg_db_subnet_ips
    content {
      cidr        = entry.value
      description = "db subnet #${entry.key + 1}"
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "pl-${var.service}-stg-sub-db-ip",
    }
  )
}

resource "aws_ec2_managed_prefix_list" "pl_esp_sub_stg_elb_ip" {
  count          = var.create_prefix_lists ? 1 : 0
  name           = "pl-${var.service}-stg-sub-elb-ip"
  address_family = "IPv4"
  max_entries    = length(var.stg_elb_subnet_ips)

  dynamic "entry" {
    for_each = var.stg_elb_subnet_ips
    content {
      cidr        = entry.value
      description = "elb subnet #${entry.key + 1}"
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "pl-${var.service}-stg-sub-elb-ip",
    }
  )
}

##################################################################
# Prd Subnet Prefix List
##################################################################
resource "aws_ec2_managed_prefix_list" "pl_esp_sub_prd_app_pod_ip" {
  count          = var.create_prefix_lists ? 1 : 0
  name           = "pl-${var.service}-prd-sub-app-pod-ip"
  address_family = "IPv4"
  max_entries    = length(var.prd_app_subnet_pod_ips)

  dynamic "entry" {
    for_each = var.prd_app_subnet_pod_ips
    content {
      cidr        = entry.value
      description = "app subnet pod #${entry.key + 1}"
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "pl-${var.service}-prd-sub-app-pod-ip",
    }
  )
}

resource "aws_ec2_managed_prefix_list" "pl_esp_sub_prd_app_vm_ip" {
  count          = var.create_prefix_lists ? 1 : 0
  name           = "pl-${var.service}-prd-sub-app-vm-ip"
  address_family = "IPv4"
  max_entries    = length(var.prd_app_subnet_vm_ips)

  dynamic "entry" {
    for_each = var.prd_app_subnet_vm_ips
    content {
      cidr        = entry.value
      description = "app subnet vm #${entry.key + 1}"
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "pl-${var.service}-prd-sub-app-vm-ip",
    }
  )
}

resource "aws_ec2_managed_prefix_list" "pl_esp_sub_prd_db_vm_ip" {
  count          = var.create_prefix_lists ? 1 : 0
  name           = "pl-${var.service}-prd-sub-db-ip"
  address_family = "IPv4"
  max_entries    = length(var.prd_db_subnet_ips)

  dynamic "entry" {
    for_each = var.prd_db_subnet_ips
    content {
      cidr        = entry.value
      description = "db subnet #${entry.key + 1}"
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "pl-${var.service}-prd-sub-db-ip",
    }
  )
}

resource "aws_ec2_managed_prefix_list" "pl_esp_sub_prd_elb_ip" {
  count          = var.create_prefix_lists ? 1 : 0
  name           = "pl-${var.service}-prd-sub-elb-ip"
  address_family = "IPv4"
  max_entries    = length(var.prd_elb_subnet_ips)

  dynamic "entry" {
    for_each = var.prd_elb_subnet_ips
    content {
      cidr        = entry.value
      description = "elb subnet #${entry.key + 1}"
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "pl-${var.service}-prd-sub-elb-ip",
    }
  )
}
##################################################################
# Shared Subnet Prefix List
##################################################################
resource "aws_ec2_managed_prefix_list" "pl_esp_sub_shared_app_pod_ip" {
  count          = var.create_prefix_lists ? 1 : 0
  name           = "pl-${var.service}-shared-sub-app-pod-ip"
  address_family = "IPv4"
  max_entries    = length(var.shared_app_subnet_pod_ips)

  dynamic "entry" {
    for_each = var.shared_app_subnet_pod_ips
    content {
      cidr        = entry.value
      description = "app subnet pod #${entry.key + 1}"
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "pl-${var.service}-shared-sub-app-pod-ip",
    }
  )
}

resource "aws_ec2_managed_prefix_list" "pl_esp_sub_shared_app_vm_ip" {
  count          = var.create_prefix_lists ? 1 : 0
  name           = "pl-${var.service}-shared-sub-app-vm-ip"
  address_family = "IPv4"
  max_entries    = length(var.shared_app_subnet_vm_ips)

  dynamic "entry" {
    for_each = var.shared_app_subnet_vm_ips
    content {
      cidr        = entry.value
      description = "app subnet vm #${entry.key + 1}"
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "pl-${var.service}-shared-sub-app-vm-ip",
    }
  )
}

resource "aws_ec2_managed_prefix_list" "pl_esp_sub_shared_db_ip" {
  count          = var.create_prefix_lists ? 1 : 0
  name           = "pl-${var.service}-shared-sub-db-ip"
  address_family = "IPv4"
  max_entries    = length(var.shared_db_subnet_ips)

  dynamic "entry" {
    for_each = var.shared_db_subnet_ips
    content {
      cidr        = entry.value
      description = "db subnet #${entry.key + 1}"
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "pl-${var.service}-shared-sub-db-ip",
    }
  )
}

resource "aws_ec2_managed_prefix_list" "pl_esp_sub_shared_elb_ip" {
  count          = var.create_prefix_lists ? 1 : 0
  name           = "pl-${var.service}-shared-sub-elb-ip"
  address_family = "IPv4"
  max_entries    = length(var.shared_elb_subnet_ips)

  dynamic "entry" {
    for_each = var.shared_elb_subnet_ips
    content {
      cidr        = entry.value
      description = "elb subnet #${entry.key + 1}"
    }
  }

  tags = merge(
    local.tags,
    {
      "Name" = "pl-${var.service}-shared-sub-elb-ip",
    }
  )
}
