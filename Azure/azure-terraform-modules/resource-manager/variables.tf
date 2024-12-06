  variable "ENV_NAME" {
    type    = string
    default = "metadefender-test"
  }
  variable "APP_NAME" {
    type    = string
    default = ""
  }
  variable "PRODUCT_ID" {
    type    = string
    default = "ani6v4vb5z4t87cymrfg3m451"
  }
  variable "SG_ID" {
    type    = string
    default = ""
  }
  variable "VPC_ID" {
    type    = string
    default = ""
  }
  variable "TARGET_GROUP_ARN_CORE" {
    type    = string
    default = ""
  }

  variable "INSTANCE_TYPE" {
    type    = string
    default = "t3.xlarge" 
  }

  variable "PUB_SUBNET_IDS" {
    type = list(string)
    default = []
  }

  variable "PRIV_SUBNET_IDS" {
    type = list(string)
    default = []
  }

  variable "WARM_POOL_ENABLED" {
    type = bool
    default = false
  }
  variable "AUTOSCALING" {
    type = bool
    default = false
  }
  variable "APP_PORT" {
    type = number
    default = 8008
  }
