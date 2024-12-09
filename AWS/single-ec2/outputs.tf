output "MD_ENV_NAME" {
  value = var.MD_ENV_NAME
}

output "VPC_ID" {
  value = module.metadefender_network.VPC_ID
}

output "MD_REGION" {
  value = var.MD_REGION
}
output "APIKEY" {
  value = var.LICENSE_KEY_CORE != "" && var.APIKEY_GENERATION  ? random_bytes.apikey[0].hex : "LICENSE_KEY and APIKEY_GENERATION needed for this value"
  sensitive = true
}