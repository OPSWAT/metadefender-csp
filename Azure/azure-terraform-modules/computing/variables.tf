  variable "PUBLIC_ENVIRONMENT" {
    type = bool
    default = true
  }
  variable "APP_NAME" {
    type    = string
    default = "metadefender"
  }
  variable "MD_REGION" {
    type    = string
    default = ""
  }

  variable "LICENSE_AUTOMATION_FUNCTION" {
    type = bool
    default = false
  }
  variable "RG_NAME" {
    type    = string
    default = "metadefender"
  }
  variable "TAGS" {
    description = "Map of the tags to use for the resources that are deployed"
    type        = map(string)
    default = {
      environment = "metadefender"
    }
  }
  variable "AUTOSCALING" {
    type = bool
    default = false
  }
  variable "APP_PORT" {
    type = number
    default = 8008
  }

  variable "LICENSE_KEY" {
    type    = string
    default = ""
  }
  variable "APIKEY" {
    type    = string
    default = ""
  }
  variable "DEPLOY_CORE" {
    type    = bool
    default = "false"  
  }
  variable "DEPLOY_ICAP" {
    type    = bool
    default = "false"  
  }
  variable "DEPLOY_MDSS" {
    type    = bool
    default = "false"  
  }
  variable "DEPLOY_MDSS_COSMOSDB" {
    type = bool
    default = false
  }
  variable "MDSS_COSMOSDB_ENDPOINT" {
    type    = string
    default = "" 
  }
  variable "INSTANCE_TYPE" {
    type    = string
    default = "" 
  }
  variable "NUMBER_INSTANCES" {
    type  = number
    default = 3
  }
  variable "VM_PWD" {
    type    = string
    default = ""
  }
  variable "SKU" {
    type    = string
    default = ""
  }
  variable "OFFER_PRODUCT" {
    type    = string
    default = ""
  }

  variable "SUBNET_ID" {
    type    = string
    default = ""
  }
  variable "APPGW_SUBNET_ID" {
    type    = string
    default = ""
  }
  variable "NSG_ID" {
    type    = string
    default = ""
  }



