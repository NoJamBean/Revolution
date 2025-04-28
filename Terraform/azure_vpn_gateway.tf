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
  enable_bgp    = false

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet.id
  }

  sku = "VpnGw1" # 가격/성능 선택 (VpnGw1이 소규모에 적당함)
}
