  variable "RG_NAME" {
    type    = string
    default = "metadefender-test"
  }
  variable "IMPORT_RG" {
    type    = bool
    default = false
  }
  variable "VM_PWD" {
    type        = string
    sensitive   = true
  }
  variable "MD_REGION" {
    type    = string
    default = "eastus"
  }

  variable "VM_KEY_NAME" {
    type    = string
    default = ""
  }
  variable "MD_VNET_CIDR" {
    type = string
    default = "192.168.0.0/16"
  }
  variable "PUBLIC_ENVIRONMENT" {
    type = bool
    default = true
  }

  variable "APIKEY_GENERATION" {
    type = bool
    default = false
  }


  variable "DEPLOY_CORE" {
    type = bool
    default = true
  }

  variable "CORE_PRODUCT_ID" {
    type    = string
    default = "ani6v4vb5z4t87cymrfg3m451"
  }

  variable "CORE_INSTANCE_TYPE" {
    type    = string
    default = "c5.2xlarge"
  }

  variable "LICENSE_KEY_CORE" {
    type = string
    default = ""
  }

  variable "CORE_PORT" {
    type = number
    default = 8008
  }
  variable "SKU_CORE" {
    type    = string
    default = ""
  }
  variable "OFFER_PRODUCT_CORE" {
    type    = string
    default = ""
  }

  variable "DEPLOY_ICAP" {
    type = bool
    default = false
  }

  variable "ICAP_PRODUCT_ID" {
    type    = string
    default = "b1w10ei2pw2vgpdsjw44pbffr"
  }

  variable "ICAP_INSTANCE_TYPE" {
    type    = string
    default = "c5.2xlarge"
  }

  variable "LICENSE_KEY_ICAP" {
    type = string
    default = ""
  }

  variable "ICAP_PORT" {
    type = number
    default = 8048
  }
  variable "SKU_ICAP" {
    type    = string
    default = ""
  }
  variable "OFFER_PRODUCT_ICAP" {
    type    = string
    default = ""
  }

  variable "DEPLOY_MDSS" {
    type = bool
    default = true
  }
  variable "DEPLOY_MDSS_COSMOSDB" {
    type = bool
    default = false
  }

  variable "MDSS_PRODUCT_ID" {
    type    = string
    default = "3mup1qubt6hwmup405eljau0k"
  }

  variable "MDSS_INSTANCE_TYPE" {
    type    = string
    default = "c5.2xlarge"
  }

  variable "MDSS_PORT" {
    type = number
    default = 80
  }
  variable "SKU_MDSS" {
    type    = string
    default = ""
  }
  variable "OFFER_PRODUCT_MDSS" {
    type    = string
    default = ""
  }