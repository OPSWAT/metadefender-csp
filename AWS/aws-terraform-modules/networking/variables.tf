  variable "ENV_NAME" {
    type    = string
    default = "metadefender-test"
  }

  variable "VPC_CIDR" {
    type = string
    default = "192.168.0.0/16"
  }
  variable "DEPLOY_ICAP" {
    type = bool
    default = false
  }
  variable "DEPLOY_MDSS" {
    type = bool
    default = false
  }
  variable "DEPLOY_MDSS_AMAZONMQ" {
    type = bool
    default = false
  }
  variable "DEPLOY_MDSS_DOCUMENTDB" {
    type = bool
    default = false
  }
  variable "DEPLOY_MDSS_ELASTICACHE" {
    type = bool
    default = false
  }  
  variable "PUBLIC" {
    type = bool
    default = true
  }
  variable "AUTOSCALING" {
    type = bool
    default = false
  }