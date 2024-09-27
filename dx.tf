# Direct Connect 연결 생성
resource "aws_dx_connection" "connection" {
  count     = var.create_dx_connection ? 1 : 0
  name      = "dx-${var.service}-${var.environment}"
  bandwidth = "1Gbps"
  # location      = "LGKNX"
  # provider_name = "KINX"
  location      = "EqSe2-EQ"
  provider_name = "Verizon"
  tags = merge(
    local.tags,
    {
      "Name" = "dx-${var.service}-${var.environment}"
    }
  )
}

# Direct Connect Gateway 생성
resource "aws_dx_gateway" "gateway" {
  count           = var.create_dx_gateway ? 1 : 0
  name            = "dgw-${var.service}-${var.environment}"
  amazon_side_asn = 64512
}

# Transit Virtual Interface 생성
resource "aws_dx_transit_virtual_interface" "vif" {
  count            = var.create_dx_transit_virtual_interface ? 1 : 0
  depends_on       = [aws_dx_connection.connection, aws_dx_gateway.gateway]
  connection_id    = aws_dx_connection.connection[0].id
  name             = "dxtvif-${var.service}"
  vlan             = 100
  address_family   = "ipv4"
  bgp_asn          = 65000
  amazon_address   = "169.254.254.1/30"
  customer_address = "169.254.254.2/30"
  dx_gateway_id    = aws_dx_gateway.gateway[0].id
  tags = merge(
    local.tags,
    {
      "Name" = "dxtvif-${var.service}-${var.environment}"
    }
  )
}

# Transit Gateway 연결
resource "aws_dx_gateway_association" "association" {
  count                 = var.create_dx_gateway_association ? 1 : 0
  depends_on            = [module.tgw, aws_dx_gateway.gateway]
  dx_gateway_id         = aws_dx_gateway.gateway[0].id
  associated_gateway_id = module.tgw[0].ec2_transit_gateway_id
  allowed_prefixes      = ["10.0.0.0/16", "172.16.0.0/12"]
}


# aws directconnect describe-locations --region ap-northeast-2

# {
#     "locations": [
#         {
#             "locationCode": "LGKNX",
#             "locationName": "KINX Gasen, Seoul, KOR",
#             "region": "ap-northeast-2",
#             "availablePortSpeeds": [
#                 "1G",
#                 "10G"
#             ],
#             "availableProviders": [
#                 "Sejong",
#                 "SK Telecom",
#                 "LG Uplus",
#                 "KINX",
#                 "Dreamline"
#             ],
#             "availableMacSecPortSpeeds": []
#         },
#         {
#             "locationCode": "LGU57",
#             "locationName": "LG U+ Pyeong-Chon Mega Center, Seoul, KOR",
#             "region": "ap-northeast-2",
#             "availablePortSpeeds": [
#                 "100G",
#                 "1G",
#                 "10G"
#             ],
#             "availableProviders": [
#                 "Sejong",
#                 "SK Telecom",
#                 "LG Uplus",
#                 "Dreamline"
#             ],
#             "availableMacSecPortSpeeds": [
#                 "100G",
#                 "10G"
#             ]
#         },
#         {
#             "locationCode": "TLS10",
#             "locationName": "Digital Realty ICN10, Seoul, KOR",
#             "region": "ap-northeast-2",
#             "availablePortSpeeds": [
#                 "100G",
#                 "1G",
#                 "10G"
#             ],
#             "availableProviders": [
#                 "LG Uplus",
#                 "SK Broadband",
#                 "Samsung SDS",
#                 "KINX",
#                 "PCCW",
#                 "Dreamline",
#                 "Korea Telecom",
#                 "Sejong Telecom"
#             ],
#             "availableMacSecPortSpeeds": [
#                 "100G",
#                 "10G"
#             ]
#         }
#     ]
# }
