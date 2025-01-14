output "PRIV_SUBNET_ID" {
  value = azurerm_subnet.subnet_priv.id
}
output "APPGW_SUBNET_ID" {
  value = azurerm_subnet.subnet_appgw.id
}
output "NSG_ID" {
  value = azurerm_network_security_group.allow_core_icap_mdss.id
}


