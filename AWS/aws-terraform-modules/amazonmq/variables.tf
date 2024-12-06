  variable "ENV_NAME" {
    type    = string
    default = "metadefender-test"
  }
  variable "PRIV_SUBNET_IDS" {
    type = list(string)
    default = []
  }
  variable "DEPLOY_MDSS_DOCUMENTDB" {
    type    = bool
    default = false
  }
  variable "MDSS_AMAZONMQ_INSTANCE_TYPE" {
    type    = string
    default = "mq.m5.large"
  }
  variable "SG_ID" {
    type    = string
    default = ""
  }
    variable "MD_REGION" {
    type    = string
    default = "eu-central-1"
  }