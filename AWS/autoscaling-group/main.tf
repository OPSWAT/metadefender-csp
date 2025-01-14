module "metadefender_network" {
  source = "../aws-terraform-modules/networking"

  VPC_CIDR          = var.MD_VPC_CIDR
  ENV_NAME          = var.MD_ENV_NAME
  DEPLOY_ICAP       = var.DEPLOY_ICAP
  DEPLOY_MDSS       = var.DEPLOY_MDSS
  DEPLOY_MDSS_AMAZONMQ    = var.DEPLOY_MDSS_AMAZONMQ
  DEPLOY_MDSS_DOCUMENTDB  = var.DEPLOY_MDSS_DOCUMENTDB
  DEPLOY_MDSS_ELASTICACHE = var.DEPLOY_MDSS_ELASTICACHE

}

resource "random_bytes" "apikey" {
  count            = (var.LICENSE_KEY_CORE != "" || var.LICENSE_KEY_ICAP != "") && var.APIKEY_GENERATION  ? 1 : 0
  length = 18
}

# Metadefender Core resources

module "metadefender_licensing_handler_core" {
  source = "../aws-terraform-modules/licensing-handler-core"
  count             = var.DEPLOY_CORE && var.LICENSE_AUTOMATION_LAMBDA && var.LICENSE_KEY_CORE != "" ? 1 :0
  ENV_NAME          = var.MD_ENV_NAME
  APP_NAME          = "Core"
  LICENSE_KEY       = var.LICENSE_KEY_CORE
  APIKEY            = var.APIKEY_GENERATION ? random_bytes.apikey[0].hex : ""
  CORE_PWD          = var.CORE_PWD
  VPC_ID            = module.metadefender_network.VPC_ID
  DEFAULT_SG_ID     = module.metadefender_network.DEFAULT_SG_ID
  SUBNET_IDS        = module.metadefender_network.PRIV_SUBNET_IDS

  depends_on = [module.metadefender_network,random_bytes.apikey]
}

module "metadefender_computing_core" {
  source = "../aws-terraform-modules/computing"
  count                     = var.DEPLOY_CORE ? 1 :0
  INSTANCE_TYPE             = var.CORE_INSTANCE_TYPE
  ENV_NAME                  = var.MD_ENV_NAME
  APP_NAME                  = "Core"
  PUB_SUBNET_IDS            = module.metadefender_network.PUB_SUBNET_IDS
  PRIV_SUBNET_IDS           = module.metadefender_network.PRIV_SUBNET_IDS
  PRODUCT_ID                = var.CORE_PRODUCT_ID
  VPC_ID                    = module.metadefender_network.VPC_ID
  SG_ID                     = module.metadefender_network.SG_ID
  APP_PORT                  = var.CORE_PORT
  WARM_POOL_ENABLED         = var.WARM_POOL_ENABLED
  AUTOSCALING               = true
  PUBLIC                    = var.PUBLIC_ENVIRONMENT
  DEPLOY_CORE               = var.DEPLOY_CORE
  APIKEY                    = var.LICENSE_KEY_CORE != "" && var.APIKEY_GENERATION && var.LICENSE_AUTOMATION_LAMBDA == false ? random_bytes.apikey[0].hex : ""
  LICENSE_KEY               = var.LICENSE_KEY_CORE != "" && var.LICENSE_AUTOMATION_LAMBDA == false ? var.LICENSE_KEY_CORE : ""
  LICENSE_AUTOMATION_LAMBDA = var.LICENSE_AUTOMATION_LAMBDA

  depends_on = [module.metadefender_licensing_handler_core,random_bytes.apikey]
}

# Metadefender ICAP resources

module "metadefender_licensing_handler_icap" {
  count             = var.DEPLOY_ICAP && var.LICENSE_AUTOMATION_LAMBDA && var.LICENSE_KEY_ICAP != "" ? 1 : 0
  source            = "../aws-terraform-modules/licensing-handler-icap"
  ENV_NAME          = var.MD_ENV_NAME
  APP_NAME          = "ICAP"
  LICENSE_KEY       = var.LICENSE_KEY_ICAP
  APIKEY            = var.APIKEY_GENERATION ? random_bytes.apikey[0].hex : ""
  ICAP_PWD          = var.ICAP_PWD
  VPC_ID            = module.metadefender_network.VPC_ID
  DEFAULT_SG_ID     = module.metadefender_network.DEFAULT_SG_ID
  SUBNET_IDS        = module.metadefender_network.PRIV_SUBNET_IDS

  depends_on = [module.metadefender_network]
}

module "metadefender_computing_icap" {
  count                     = var.DEPLOY_ICAP ? 1 : 0
  source                    = "../aws-terraform-modules/computing"

  INSTANCE_TYPE             = var.ICAP_INSTANCE_TYPE
  ENV_NAME                  = var.MD_ENV_NAME
  APP_NAME                  = "ICAP"
  PUB_SUBNET_IDS            = module.metadefender_network.PUB_SUBNET_IDS
  PRIV_SUBNET_IDS           = module.metadefender_network.PRIV_SUBNET_IDS
  PRODUCT_ID                = var.ICAP_PRODUCT_ID
  SG_ID                     = module.metadefender_network.SG_ID
  VPC_ID                    = module.metadefender_network.VPC_ID
  APP_PORT                  = var.ICAP_PORT
  WARM_POOL_ENABLED         = var.WARM_POOL_ENABLED
  AUTOSCALING               = true
  PUBLIC                    = var.PUBLIC_ENVIRONMENT
  DEPLOY_ICAP               = var.DEPLOY_ICAP
  APIKEY                    = var.LICENSE_KEY_ICAP != "" && var.APIKEY_GENERATION && var.LICENSE_AUTOMATION_LAMBDA == false ? random_bytes.apikey[0].hex : ""
  LICENSE_KEY               = var.LICENSE_KEY_ICAP != "" && var.LICENSE_AUTOMATION_LAMBDA == false ? var.LICENSE_KEY_ICAP : ""
  LICENSE_AUTOMATION_LAMBDA = var.LICENSE_AUTOMATION_LAMBDA

  depends_on = [module.metadefender_licensing_handler_icap,random_bytes.apikey]
}

# Metadefender Storage Security resources

module "metadefender_iam_mdss" {
  count                     = var.DEPLOY_MDSS && (var.DEPLOY_MDSS_DOCUMENTDB || var.DEPLOY_MDSS_AMAZONMQ || var.DEPLOY_MDSS_ELASTICACHE) ? 1 : 0
  source                    = "../aws-terraform-modules/iam"
  ENV_NAME                  = var.MD_ENV_NAME
  APP_NAME                  = "MDSS"
  DEPLOY_MDSS_DOCUMENTDB    = var.DEPLOY_MDSS_DOCUMENTDB
  DEPLOY_MDSS_AMAZONMQ      = var.DEPLOY_MDSS_AMAZONMQ
  DEPLOY_MDSS_ELASTICACHE   = var.DEPLOY_MDSS_ELASTICACHE
  MDSS_DOCUDB_ARN           = var.DEPLOY_MDSS_DOCUMENTDB ? module.metadefender_documentdb_mdss[0].docdb_secret_arn : null
  MDSS_AMAZONMQ_ARN         = var.DEPLOY_MDSS_AMAZONMQ ? module.metadefender_amazonmq_mdss[0].mq_secret_arn : null
  MDSS_ELASTICACHE_ARN      = var.DEPLOY_MDSS_ELASTICACHE ? module.metadefender_elasticache_mdss[0].elasticache_secret_arn : null
  
 depends_on = [module.metadefender_amazonmq_mdss, module.metadefender_documentdb_mdss, module.metadefender_elasticache_mdss] 

}

module "metadefender_documentdb_mdss" {
  count                           = var.DEPLOY_MDSS_DOCUMENTDB ? 1 : 0
  source                          = "../aws-terraform-modules/documentdb"
  ENV_NAME                        = var.MD_ENV_NAME
  PRIV_SUBNET_IDS                 = module.metadefender_network.PRIV_SUBNET_IDS
  SG_ID                           = module.metadefender_network.SG_ID
  MDSS_DOCUMENTDB_INSTANCE_CLASS  = var.MDSS_DOCUMENTDB_INSTANCE_CLASS

  depends_on = [module.metadefender_network]
}

module "metadefender_amazonmq_mdss" {
  count                     = var.DEPLOY_MDSS_AMAZONMQ ? 1 : 0
  source                    = "../aws-terraform-modules/amazonmq"
  ENV_NAME                  = var.MD_ENV_NAME
  MD_REGION                 = var.MD_REGION
  PRIV_SUBNET_IDS           = module.metadefender_network.PRIV_SUBNET_IDS
  SG_ID                     = module.metadefender_network.SG_ID
  MDSS_AMAZONMQ_INSTANCE_TYPE = var.MDSS_AMAZONMQ_INSTANCE_TYPE

  depends_on = [module.metadefender_network]
}

module "metadefender_elasticache_mdss" {
  count                       = var.DEPLOY_MDSS_ELASTICACHE ? 1 : 0
  source                      = "../aws-terraform-modules/elasticache"
  ENV_NAME                    = var.MD_ENV_NAME
  PRIV_SUBNET_IDS             = module.metadefender_network.PRIV_SUBNET_IDS
  SG_ID                       = module.metadefender_network.SG_ID
  MDSS_ELASTICACHE_NODE_TYPE  = var.MDSS_ELASTICACHE_NODE_TYPE

  depends_on = [module.metadefender_network]
}

module "metadefender_computing_mdss" {
  count                     = var.DEPLOY_MDSS ? 1 : 0
  source                    = "../aws-terraform-modules/computing"
  DEPLOY_MDSS               = var.DEPLOY_MDSS
  INSTANCE_TYPE             = var.MDSS_INSTANCE_TYPE
  ENV_NAME                  = var.MD_ENV_NAME
  APP_NAME                  = "MDSS"
  MD_REGION                 = var.MD_REGION
  PUB_SUBNET_IDS            = module.metadefender_network.PUB_SUBNET_IDS
  PRIV_SUBNET_IDS           = module.metadefender_network.PRIV_SUBNET_IDS
  PRODUCT_ID                = var.MDSS_PRODUCT_ID
  SG_ID                     = module.metadefender_network.SG_ID
  VPC_ID                    = module.metadefender_network.VPC_ID
  APP_PORT                  = var.MDSS_PORT
  PUBLIC                    = var.PUBLIC_ENVIRONMENT
  DEPLOY_MDSS_AMAZONMQ      = var.DEPLOY_MDSS_AMAZONMQ
  DEPLOY_MDSS_DOCUMENTDB    = var.DEPLOY_MDSS_DOCUMENTDB
  DEPLOY_MDSS_ELASTICACHE   = var.DEPLOY_MDSS_ELASTICACHE
  MDSS_AMAZONMQ_SECRET_ARN        = var.DEPLOY_MDSS_AMAZONMQ ? module.metadefender_amazonmq_mdss[0].mq_secret_arn : null
  MDSS_DOCUMENTDB_SECRET_ARN      = var.DEPLOY_MDSS_DOCUMENTDB ? module.metadefender_documentdb_mdss[0].docdb_secret_arn : null
  MDSS_ELASTICACHE_SECRET_ARN     = var.DEPLOY_MDSS_ELASTICACHE ? module.metadefender_elasticache_mdss[0].elasticache_secret_arn : null
  MDSS_IAM_INSTANCE_PROFILE_ARN   = (var.DEPLOY_MDSS_DOCUMENTDB || var.DEPLOY_MDSS_AMAZONMQ || var.DEPLOY_MDSS_ELASTICACHE) ? module.metadefender_iam_mdss[0].instance_profile_arn : null

  WARM_POOL_ENABLED         = var.WARM_POOL_ENABLED
  AUTOSCALING               = true

  depends_on = [module.metadefender_network,  module.metadefender_iam_mdss] 
}