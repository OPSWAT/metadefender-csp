output "PRIV_SUBNET_ID" {
  value = azurerm_subnet.subnet_priv.id
}
output "FUNC_SUBNET_ID" {
  value = var.LICENSE_AUTOMATION_FUNCTION ? azurerm_subnet.function_subnet[0].id : ""
}
output "APPGW_SUBNET_ID" {
  value = azurerm_subnet.subnet_appgw.id
}
output "NSG_ID" {
  value = azurerm_network_security_group.allow_core_icap_mdss.id
}


