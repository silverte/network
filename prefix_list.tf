resource "aws_ec2_managed_prefix_list" "prx_esp_office_ip" {
  name           = "prx-${var.service}-office-ip"
  address_family = "IPv4"
  max_entries    = 3

  entry {
    cidr        = "10.65.10.0/24"
    description = "Jinyang Office 1"
  }

  entry {
    cidr        = "10.65.20.0/24"
    description = "Jinyang Office 2"
  }

  entry {
    cidr        = "10.65.30.0/24"
    description = "Jinyang Office 3"
  }

  tags = merge(
    local.tags,
    {
      "Name" = "prx-${var.service}-office-ip",
    }
  )
}


resource "aws_ec2_managed_prefix_list" "prx_esp_dbsafer_ip" {
  name           = "prx-${var.service}-dbsafer-ip"
  address_family = "IPv4"
  max_entries    = 4

  entry {
    cidr        = "10.100.10.197/32"
    description = "DBSafer gateway 1"
  }

  entry {
    cidr        = "10.100.10.198/32"
    description = "DBSafer gateway 2"
  }

  entry {
    cidr        = "10.100.10.204/32"
    description = "DBSafer management 1"
  }

  entry {
    cidr        = "10.100.10.210/32"
    description = "DBSafer management 2"
  }

  tags = merge(
    local.tags,
    {
      "Name" = "prx-${var.service}-dbsafer-ip",
    }
  )
}
