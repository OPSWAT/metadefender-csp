  variable "ENV_NAME" {
    type    = string
    default = "metadefender"
  }
  variable "APP_NAME" {
    type    = string
    default = ""
  }
  variable "RG_NAME" {
    type    = string
    default = ""
    description = "The name of the Azure resource group."
  }
  variable "RG_ID" {
    type    = string
    default = ""
  }
  variable "VMSS_ID" {
    type    = string
    default = ""
  }
  variable "SUBNET_ID" {
    type    = string
    default = ""
  }
  variable "LOCATION" {
    type    = string
    default = ""
  }
  variable "SA_ACCOUNT_TIER" {
    description = "The tier of the storage account. Possible values are Standard and Premium."
    type        = string
    default     = "Standard"
  }

  variable "SA_ACCOUNT_REPLICATION_TYPE" {
    description = "The replication type of the storage account. Possible values are LRS, GRS, RAGRS, and ZRS."
    type        = string
    default     = "LRS"
  }
  variable "RUNTIME_NAME" {
    description = "The name of the language worker runtime."
    type        = string
    default     = "python" # Allowed: dotnet-isolated, java, node, powershell, python
  }
  
  variable "RUNTIME_VERSION" {
    description = "The version of the language worker runtime."
    type        = string
    default     = "3.10" # Supported versions: see https://aka.ms/flexfxversions
  }
  variable "LICENSE_KEY" {
    type = string
    default = ""
  }
  variable "APIKEY" {
    type = string
    default = ""
  }
  variable "CORE_USER" {
    type = string
    default = ""
  }
  variable "CORE_PWD" {
    type = string
    default = ""
  }

