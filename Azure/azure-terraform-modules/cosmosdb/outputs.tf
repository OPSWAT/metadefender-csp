output "cosmosdb_endpoint" {
  description = "Primary connection string for the CosmosDB instance using MongoDB 6.0"
  value       = replace(azurerm_cosmosdb_account.cosmosdb_60.primary_mongodb_connection_string, "/?ssl=", "/MDCS?ssl=")
}
