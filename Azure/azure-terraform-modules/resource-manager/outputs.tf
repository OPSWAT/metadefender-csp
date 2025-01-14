output "RG_NAME" {
  value = var.IMPORT_RG ? data.azurerm_resource_group.rg[0].name : azurerm_resource_group.rg[0].name
}