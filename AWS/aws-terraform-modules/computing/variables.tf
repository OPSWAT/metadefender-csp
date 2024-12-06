  variable "ENV_NAME" {
    type    = string
    default = "metadefender-test"
  }
  variable "APP_NAME" {
    type    = string
    default = ""
  }
    variable "MD_REGION" {
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
  variable "LICENSE_KEY" {
    type    = string
    default = ""
  }
  variable "APIKEY" {
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

  variable "EC2_KEY_NAME" {
    type    = string
    default = ""
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
  variable "PUBLIC" {
    type = bool
    default = true
  }
  variable "EIP" {
    type    = string
    default = "" 
  }
  variable "DEPLOY_CORE" {
    type    = bool
    default = "false"  
  }
  variable "LICENSE_AUTOMATION_LAMBDA" {
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
  variable "DEPLOY_MDSS_AMAZONMQ" {
    type    = bool
    default = "false" 
  }
  variable "MDSS_AMAZONMQ_SECRET_ARN" {
    type    = string
    default = "" 
  }
   variable "DEPLOY_MDSS_DOCUMENTDB" {
    type    = bool
    default = "false" 
  }
  variable "MDSS_DOCUMENTDB_SECRET_ARN" {
    type    = string
    default = "" 
  }
  variable "DEPLOY_MDSS_ELASTICACHE" {
    type    = bool
    default = "false" 
  }
  variable "MDSS_ELASTICACHE_SECRET_ARN" {
    type    = string
    default = "" 
  }
  variable "MDSS_IAM_INSTANCE_PROFILE_ARN" {
    type = string
    default = ""
  }
