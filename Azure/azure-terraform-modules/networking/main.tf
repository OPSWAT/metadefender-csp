
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.RG_NAME}-vnet"
  location            = var.MD_REGION
  resource_group_name = var.RG_NAME
  address_space       = [var.MD_VNET_CIDR]
}

resource "azurerm_subnet" "subnet_appgw" {
  name                 = "${var.RG_NAME}-appgw-subnet"
  resource_group_name  = var.RG_NAME
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.MD_VNET_CIDR, 4, 1)]
}
resource "azurerm_subnet" "subnet_priv" {
  name                 = "${var.RG_NAME}-priv-subnet"
  resource_group_name  = var.RG_NAME
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.MD_VNET_CIDR, 4, 2)]
}

#resource "azurerm_resource_provider_registration" "ms_app" {
#  name = "Microsoft.App"
#}

resource "azurerm_subnet" "function_subnet" {
  count                = var.LICENSE_AUTOMATION_FUNCTION ? 1 : 0
  name                 = "${var.RG_NAME}-function-subnet"
  resource_group_name  = var.RG_NAME
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.MD_VNET_CIDR, 4, 3)]
  default_outbound_access_enabled = false
  service_endpoints    = [
    "Microsoft.KeyVault",
    "Microsoft.Storage",
  ]
  delegation {
    name = "delegation"
    service_delegation {
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
        ]
        name    = "Microsoft.App/environments"
    }
  }
}


resource "azurerm_network_security_group" "allow_core_icap_mdss" {
  name                = "allow_core_icap_mdss"
  location            = var.MD_REGION
  resource_group_name = var.RG_NAME
}


resource "azurerm_network_security_rule" "allow_core_port" {
  count                       = var.DEPLOY_CORE ? 1 : 0
  name                        = "CoreREST"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8008"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.RG_NAME
  network_security_group_name = azurerm_network_security_group.allow_core_icap_mdss.name
}
resource "azurerm_network_security_rule" "allow_ssh_port" {
  count                       = var.DEPLOY_MDSS ? 1 : 0
  name                        = "SSH"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.RG_NAME
  network_security_group_name = azurerm_network_security_group.allow_core_icap_mdss.name
}

resource "azurerm_network_security_rule" "allow_icap_port" {
  count                       = var.DEPLOY_ICAP ? 1 : 0
  name                        = "ICAPREST"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8048"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.RG_NAME
  network_security_group_name = azurerm_network_security_group.allow_core_icap_mdss.name
}

resource "azurerm_network_security_rule" "allow_icap_port_2" {
  count                       = var.DEPLOY_ICAP ? 1 : 0
  name                        = "ICAPPORT"
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1344"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.RG_NAME
  network_security_group_name = azurerm_network_security_group.allow_core_icap_mdss.name
}
resource "azurerm_network_security_rule" "allow_mdss_port" {
  count                       = var.DEPLOY_MDSS ? 1 : 0
  name                        = "MDSSUI"
  priority                    = 104
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.RG_NAME
  network_security_group_name = azurerm_network_security_group.allow_core_icap_mdss.name
}
resource "azurerm_network_security_rule" "allow_cosmosdb_port" {
  count                       = var.DEPLOY_MDSS && var.DEPLOY_MDSS_COSMOSDB ? 1 : 0
  name                        = "ComosDB"
  priority                    = 105
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "10255"
  source_address_prefix       = var.MD_VNET_CIDR
  destination_address_prefix  = "*"
  resource_group_name         = var.RG_NAME
  network_security_group_name = azurerm_network_security_group.allow_core_icap_mdss.name
}
resource "azurerm_network_security_rule" "allow_appgw_port" {
  name                        = "APPGW"
  priority                    = 106
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "65200-65535"  # Allow this port range
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.RG_NAME
  network_security_group_name = azurerm_network_security_group.allow_core_icap_mdss.name
}

resource "azurerm_subnet_network_security_group_association" "subnet-appgw-nsg-association" {
  subnet_id                 = azurerm_subnet.subnet_appgw.id
  network_security_group_id = azurerm_network_security_group.allow_core_icap_mdss.id
}
resource "azurerm_subnet_network_security_group_association" "subnet-priv-nsg-association" {
  subnet_id                 = azurerm_subnet.subnet_priv.id
  network_security_group_id = azurerm_network_security_group.allow_core_icap_mdss.id
}
resource "azurerm_subnet_network_security_group_association" "subnet-func-nsg-association" {
  count                = var.LICENSE_AUTOMATION_FUNCTION ? 1 : 0
  subnet_id                 = azurerm_subnet.function_subnet[0].id
  network_security_group_id = azurerm_network_security_group.allow_core_icap_mdss.id
}

resource "azurerm_public_ip" "NATpublicIp" {
  name                = "${var.RG_NAME}-natpublic-ip"
  location            = var.MD_REGION
  resource_group_name = var.RG_NAME
  allocation_method   = "Static"
}

resource "azurerm_nat_gateway" "natgw" {
  name                = "${var.RG_NAME}-nat-gateway"
  location            = var.MD_REGION
  resource_group_name = var.RG_NAME
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "natgwpubipass" {
  nat_gateway_id       = azurerm_nat_gateway.natgw.id
  public_ip_address_id = azurerm_public_ip.NATpublicIp.id
}

resource "azurerm_subnet_nat_gateway_association" "natgwtosubnet" {
  subnet_id     = azurerm_subnet.subnet_priv.id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}

resource "azurerm_subnet_nat_gateway_association" "natgwtosubnetFunc" {
  count                = var.LICENSE_AUTOMATION_FUNCTION ? 1 : 0
  subnet_id                 = azurerm_subnet.function_subnet[0].id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}
