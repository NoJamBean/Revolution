# resource "azurerm_dns_resolver" "resolver_1" {
#   name                = "azure-dns-resolver"
#   resource_group_name = azurerm_resource_group.main.name
#   location            = azurerm_resource_group.main.location

#   virtual_network_id  = azurerm_virtual_network.vnet.id
# }