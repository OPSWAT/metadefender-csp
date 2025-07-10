  variable "RG_NAME" {
    type    = string
    default = "metadefender"
  }
  variable "MD_REGION" {
    type    = string
    default = ""
  }
  variable "MD_VNET_CIDR" {
    type    = string
    default = ""
  }

  variable "DEPLOY_CORE" {
    type = bool
    default = true
  }

  variable "DEPLOY_ICAP" {
    type = bool
    default = false
  }

  variable "DEPLOY_MDSS" {
    type = bool
    default = false
  }

  variable "DEPLOY_MDSS_COSMOSDB" {
    type = bool
    default = false
  }
  variable "LICENSE_AUTOMATION_FUNCTION" {
    type = bool
    default = false
  }
