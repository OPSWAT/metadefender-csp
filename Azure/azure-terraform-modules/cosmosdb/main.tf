

resource "azurerm_cosmosdb_account" "cosmosdb_60" {
  name                = "${var.RG_NAME}-cosmosdb60"
  location            = var.MD_REGION
  resource_group_name = var.RG_NAME
  offer_type          = "Standard"
  kind                = "MongoDB"
  mongo_server_version = "6.0"
  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.MD_REGION
    failover_priority = 0
  }
  is_virtual_network_filter_enabled = true
  virtual_network_rule {
    id = var.SUBNET_ID
    ignore_missing_vnet_service_endpoint = true
  }

  capabilities {
    name = "EnableMongo"
  }
}


resource "azurerm_cosmosdb_mongo_database" "mdcsdb60" {
  name                = "MDCS"
  resource_group_name = var.RG_NAME
  account_name        = azurerm_cosmosdb_account.cosmosdb_60.name
  autoscale_settings {
    max_throughput = 10000
  }

}