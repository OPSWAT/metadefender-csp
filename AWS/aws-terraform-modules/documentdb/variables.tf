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
  variable "MDSS_DOCUMENTDB_INSTANCE_CLASS" {
    type    = string
    default = "db.r5.large"
  }
  variable "SG_ID" {
    type    = string
    default = ""
  }