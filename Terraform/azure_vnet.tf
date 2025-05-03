resource "azurerm_resource_group" "main" {
  name     = "rg-webapp"
  location = "Korea Central"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-webapp"
  address_space       = ["10.2.0.0/16"] # Azure쪽 대역 (AWS에서 Static Route 등록했던 그거)
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  dns_servers = [
    "10.0.100.10",
    "10.0.15.10",
    "8.8.8.8"
  ]
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-webapp"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.2.1.0/24"]

  delegation {
    name = "delegation-to-app-service"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

# vpn gateway용 서브넷

resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet" # 이름 수정 불가
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.2.2.0/24"] #["10.2.254.0/27"]
}

# 라우팅 테이블 생성
resource "azurerm_route_table" "example" {
  name                 = "example-route-table"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name

  route {
    name                   = "aws-route"
    address_prefix         = "10.0.0.0/16"  # AWS VPC의 CIDR 블록
    next_hop_type          = "VirtualNetworkGateway"
  }
}

# 서브넷에 라우팅 테이블 연결
resource "azurerm_subnet_route_table_association" "example" {
  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = azurerm_route_table.example.id
}