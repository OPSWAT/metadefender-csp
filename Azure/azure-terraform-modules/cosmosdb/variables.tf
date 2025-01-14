variable "MD_REGION" {
  description = "Azure Region for CosmosDB deployment"
  type        = string
}

variable "RG_NAME" {
  description = "Resource group name for CosmosDB"
  type        = string
}
variable "SUBNET_ID" {
  description = "The private subnet ID for CosmosDB"
  type        = string
}