  variable "MD_ENV_NAME" {
    type    = string
    default = "metadefender-test"
  }

  variable "MD_REGION" {
    type    = string
    default = "eu-central-1"
  }

  variable "EC2_KEY_NAME" {
    type    = string
    default = ""
  }

  variable "ACCESS_KEY_ID" {
    type    = string
    default = ""
  }

  variable "SECRET_ACCESS_KEY" {
    type    = string
    default = ""
  }
  variable "MD_VPC_CIDR" {
    type = string
    default = "192.168.0.0/16"
  }
  
  variable "DEPLOY_CORE" {
    type = bool
    default = true
  }
  variable "LICENSE_AUTOMATION_LAMBDA" {
    type = bool
    default = false
  }
  variable "APIKEY_GENERATION" {
    type = bool
    default = false
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
  variable "CORE_PWD" {
    type = string
    default = ""
  }

  variable "CORE_PORT" {
    type = number
    default = 8008
  }
  variable "DEPLOY_ICAP" {
    type = bool
    default = false
  }

  variable "ICAP_PRODUCT_ID" {
    type    = string
    default = "b1w10ei2pw2vgpdsjw44pbffr"
  }
  variable "ICAP_PORT" {
    type = number
    default = 8048
  }

  variable "ICAP_INSTANCE_TYPE" {
    type    = string
    default = "c5.2xlarge"
  }

  variable "LICENSE_KEY_ICAP" {
    type = string
    default = ""
  }

  variable "DEPLOY_MDSS" {
    type = bool
    default = true
  }

  variable "DEPLOY_MDSS_DOCUMENTDB" {
    type = bool
    default = false
  }

  variable "MDSS_DOCUMENTDB_INSTANCE_CLASS" {
    type = string
    default = "db.r5.large"
  }

  variable "DEPLOY_MDSS_AMAZONMQ" {
    type = bool
    default = false
  }

  variable "MDSS_AMAZONMQ_INSTANCE_TYPE" {
    type = string
    default = "mq.m5.large"
  }
  
  variable "DEPLOY_MDSS_ELASTICACHE" {
    type = bool
    default = false
  }

  variable "MDSS_ELASTICACHE_NODE_TYPE" {
    type = string
    default = "cache.m5.large"
  }

  variable "MDSS_PRODUCT_ID" {
    type    = string
    default = "3mup1qubt6hwmup405eljau0k"
  }
  variable "MDSS_PORT" {
    type = number
    default = 80
  }

  variable "MDSS_INSTANCE_TYPE" {
    type    = string
    default = "c5.2xlarge"
  }

  # variable "LICENSE_KEY_MDSS" {
  #   type = string
  #   default = ""
  # }

  variable "PUBLIC_ENVIRONMENT" {
    type = bool
    default = true
  }