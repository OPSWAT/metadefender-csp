
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.ENV_NAME}-vnet"
  location            = var.MD_REGION
  resource_group_name = var.RG_NAME
  address_space       = [var.MD_VPC_CIDR]
}

resource "azurerm_subnet" "subnet_pub" {
  name                 = "${var.ENV_NAME}-public-subnet"
  resource_group_name  = var.RG_NAME
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = cidrsubnet(azurerm_virtual_network.vnet.address_space, 3, 1)
}
resource "azurerm_subnet" "subnet_priv" {
  name                 = "${var.ENV_NAME}-priv-subnet"
  resource_group_name  = var.RG_NAME
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = cidrsubnet(azurerm_virtual_network.vnet.address_space, 3, 2)
}
