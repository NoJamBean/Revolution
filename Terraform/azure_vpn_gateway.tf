resource "azurerm_public_ip" "vpn_gateway_pip" {
  name                = "vpn-gateway-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"

  sku = "Standard" // Standard 로 고정 (VPN Gatewaysms "Basic" 안 됨)
}



resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  name                = "vnet-gateway"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  type     = "Vpn"
  vpn_type = "RouteBased" # (PolicyBased 말고 RouteBased 사용)

  active_active = false
  enable_bgp    = true

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet.id
  }

  sku = "VpnGw1" # 가격/성능 선택 (VpnGw1이 소규모에 적당함)
}



locals {
  tunnels ={
    aws_tunnel1_ip = tostring(aws_vpn_connection.vpn_connection.tunnel1_address)
    aws_tunnel2_ip = tostring(aws_vpn_connection.vpn_connection.tunnel2_address)
  }
}

# azure - local gateway
resource "azurerm_local_network_gateway" "aws_cgw" {
  for_each = local.tunnels
  name                = "aws-cgw-${each.key}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  gateway_address = each.value #
  address_space = [
    "10.0.0.0/14" # AWS VPC CIDR
  ]
  bgp_settings {
    asn                  = 65000  # BGP ASN 설정
    bgp_peering_address   = "4.230.31.128"  # BGP 피어링 주소 (AWS VPN의 내부 IP)
    peer_weight           = 0  # BGP 피어링의 가중치 (선택 사항)
  }
}

resource "azurerm_virtual_network_gateway_connection" "aws_connection" {
  for_each            = azurerm_local_network_gateway.aws_cgw
  name                = "aws-connection-${each.key}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway.id
  local_network_gateway_id   = each.value.id
  shared_key                 = "MyToToRoSecretSharedKey123" # AWS 측과 동일하게 설정

  connection_protocol = "IKEv2"
  enable_bgp          = false

  ipsec_policy {
    dh_group         = "DHGroup2"
    ike_encryption   = "AES256"
    ike_integrity    = "SHA256"
    ipsec_encryption = "AES256"
    ipsec_integrity  = "SHA256"
    pfs_group        = "PFS2"
    sa_lifetime      = 28800
    sa_datasize      = 102400000
  }
}


