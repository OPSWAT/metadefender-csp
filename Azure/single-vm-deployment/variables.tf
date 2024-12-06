  variable "MD_ENV_NAME" {
    type    = string
    default = "metadefender-test"
  }

  variable "MD_REGION" {
    type    = string
    default = ""
  }

  variable "MD_VPC_CIDR" {
    type = string
    default = "192.168.0.0/16"
  }
  variable "CORE_INSTANCE_TYPE" {
    type    = string
    default = ""
  }

  variable "LICENSE_KEY_CORE" {
    type = string
    default = ""
  }
  variable "DEPLOY_ICAP" {
    type = bool
    default = false
  }

  variable "ICAP_INSTANCE_TYPE" {
    type    = string
    default = ""
  }

  variable "LICENSE_KEY_ICAP" {
    type = string
    default = ""
  }
