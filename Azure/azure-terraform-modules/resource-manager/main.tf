# Generate random resource group name
resource "random_pet" "rg-name" {
  count = var.IMPORT_RG ? 0 : 1
  prefix = var.RG_NAME
  length = 1
}

resource "azurerm_resource_group" "rg" {
  count = var.IMPORT_RG ? 0 : 1
  name     = random_pet.rg-name[0].id
  location = var.MD_REGION
}

data "azurerm_resource_group" "rg" {
  count = var.IMPORT_RG ? 1 : 0
  name  = var.RG_NAME
}