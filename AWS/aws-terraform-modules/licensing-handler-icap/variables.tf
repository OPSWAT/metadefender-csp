  variable "ENV_NAME" {
    type    = string
    default = "metadefender-test"
  }
  variable "APP_NAME" {
    type    = string
    default = "metadefender-test"
  }
  variable "LICENSE_KEY" {
    type = string
    default = ""
  }
  variable "APIKEY" {
    type = string
    default = ""
  }
  variable "ICAP_PWD" {
    type = string
    default = ""
  }
  variable "VPC_ID" {
    type = string
    default = ""
  }
  variable "DEFAULT_SG_ID" {
    type = string
    default = ""
  }
  variable "SUBNET_IDS" {
    type = list(string)
    default = []
  }


