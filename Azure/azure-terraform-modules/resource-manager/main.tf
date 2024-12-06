# Generate random resource group name
resource "random_pet" "rg-name" {
  prefix = "metadefender-${var.ENV_NAME}"
}

resource "azurerm_resource_group" "k8s" {
  name     = random_pet.rg-name.id
  location = var.MD_REGION
}
