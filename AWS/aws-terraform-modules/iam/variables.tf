variable "ENV_NAME" {
  description = "The environment name (e.g., dev, staging, prod)."
  type        = string
}

variable "APP_NAME" {
  description = "The name of the application."
  type        = string
}

variable "DEPLOY_MDSS_DOCUMENTDB" {
  type    = bool
  default = false
}
variable "DEPLOY_MDSS_AMAZONMQ" {
  type    = bool
  default = false
}
variable "DEPLOY_MDSS_ELASTICACHE" {
  type    = bool
  default = false
}

variable "MDSS_DOCUDB_ARN" {
    type = string
    default = ""
}
variable "MDSS_AMAZONMQ_ARN" {
    type = string
    default = ""
}
variable "MDSS_ELASTICACHE_ARN" {
    type = string
    default = ""
}