  variable "ENV_NAME" {
    type    = string
    default = "metadefender-test"
  }
  variable "DEPLOY_MDSS_ELASTICACHE" {
    type    = bool
    default = false
  }
  variable "PRIV_SUBNET_IDS" {
    type = list(string)
    default = []
  }
  variable "MDSS_ELASTICACHE_NODE_TYPE" {
    type    = string
    default = ""
  }
  variable "SG_ID" {
    type    = string
    default = ""
  }