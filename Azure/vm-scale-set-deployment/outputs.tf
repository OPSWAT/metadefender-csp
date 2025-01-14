output "APIKEY" {
  value = var.LICENSE_KEY_CORE != "" && var.APIKEY_GENERATION   ? random_bytes.apikey[0].hex : ""
  sensitive = true
}