module "metadefender_resource_manager" {
    source ="../azure-terraform-modules/resource-manager"

    RG_NAME = var.RG_NAME
    IMPORT_RG = var.IMPORT_RG
    MD_REGION = var.MD_REGION

}

module "metadefender_network" {
  source = "../azure-terraform-modules/networking"

  MD_VNET_CIDR              = var.MD_VNET_CIDR
  MD_REGION                 = var.MD_REGION
  RG_NAME                   = var.IMPORT_RG ? var.RG_NAME : module.metadefender_resource_manager.RG_NAME
  DEPLOY_CORE               = var.DEPLOY_CORE
  DEPLOY_ICAP               = var.DEPLOY_ICAP
  DEPLOY_MDSS               = var.DEPLOY_MDSS
  DEPLOY_MDSS_COSMOSDB      = var.DEPLOY_MDSS_COSMOSDB
}

resource "random_bytes" "apikey" {
  count             = (var.LICENSE_KEY_CORE != "" || var.LICENSE_KEY_ICAP != "") && var.APIKEY_GENERATION  ? 1 : 0
  length            = 18
}

# Metadefender Core resources

module "metadefender_computing_core" {
  source                    = "../azure-terraform-modules/computing"
  count                     = var.DEPLOY_CORE ? 1 : 0
  PUBLIC_ENVIRONMENT        = var.PUBLIC_ENVIRONMENT
  APP_NAME                  = "core"
  MD_REGION                 = var.MD_REGION
  RG_NAME                   = var.IMPORT_RG ? var.RG_NAME : module.metadefender_resource_manager.RG_NAME
  APP_PORT                  = var.CORE_PORT
  LICENSE_KEY               = var.LICENSE_KEY_CORE
  APIKEY                    = var.LICENSE_KEY_CORE != "" && var.APIKEY_GENERATION   ? random_bytes.apikey[0].hex : ""
  DEPLOY_CORE               = var.DEPLOY_CORE
  INSTANCE_TYPE             = var.CORE_INSTANCE_TYPE
  VM_PWD                    = var.VM_PWD
  OFFER_PRODUCT             = var.OFFER_PRODUCT_CORE
  SKU                       = var.SKU_CORE
  SUBNET_ID                 = var.PUBLIC_ENVIRONMENT ? module.metadefender_network.PUB_SUBNET_ID : module.metadefender_network.PRIV_SUBNET_ID
  NSG_ID                    = module.metadefender_network.NSG_ID

  depends_on = [module.metadefender_network,random_bytes.apikey,module.metadefender_resource_manager]
}

# Metadefender ICAP Server resources

module "metadefender_computing_icap" {
  source                    = "../azure-terraform-modules/computing"
  count                     = var.DEPLOY_ICAP ? 1 : 0
  PUBLIC_ENVIRONMENT        = var.PUBLIC_ENVIRONMENT
  APP_NAME                  = "icap"
  MD_REGION                 = var.MD_REGION
  RG_NAME                   = var.IMPORT_RG ? var.RG_NAME : module.metadefender_resource_manager.RG_NAME
  APP_PORT                  = var.ICAP_PORT
  LICENSE_KEY               = var.LICENSE_KEY_ICAP
  APIKEY                    = var.LICENSE_KEY_ICAP != "" && var.APIKEY_GENERATION   ? random_bytes.apikey[0].hex : ""
  DEPLOY_ICAP               = var.DEPLOY_ICAP
  INSTANCE_TYPE             = var.ICAP_INSTANCE_TYPE
  VM_PWD                    = var.VM_PWD
  OFFER_PRODUCT             = var.OFFER_PRODUCT_ICAP
  SKU                       = var.SKU_ICAP
  SUBNET_ID                 = var.PUBLIC_ENVIRONMENT ? module.metadefender_network.PUB_SUBNET_ID : module.metadefender_network.PRIV_SUBNET_ID
  NSG_ID                    = module.metadefender_network.NSG_ID

  depends_on = [module.metadefender_network,random_bytes.apikey,module.metadefender_resource_manager]
}

# Metadefender Storage Security resources

module "metadefender_cosmosdb_mdss" {
  count                          = var.DEPLOY_MDSS_COSMOSDB ? 1 : 0
  source                         = "../azure-terraform-modules/cosmosdb"
  RG_NAME                        = var.IMPORT_RG ? var.RG_NAME : module.metadefender_resource_manager.RG_NAME
  MD_REGION                      = var.MD_REGION
  SUBNET_ID                      = var.PUBLIC_ENVIRONMENT ? module.metadefender_network.PUB_SUBNET_ID : module.metadefender_network.PRIV_SUBNET_ID

  depends_on = [module.metadefender_network,module.metadefender_resource_manager]
}

module "metadefender_computing_mdss" {
  source                    = "../azure-terraform-modules/computing"
  count                     = var.DEPLOY_MDSS ? 1 : 0
  PUBLIC_ENVIRONMENT        = var.PUBLIC_ENVIRONMENT
  APP_NAME                  = "storage-security"
  MD_REGION                 = var.MD_REGION
  RG_NAME                   = var.IMPORT_RG ? var.RG_NAME : module.metadefender_resource_manager.RG_NAME
  APP_PORT                  = var.MDSS_PORT
  DEPLOY_MDSS               = var.DEPLOY_MDSS
  INSTANCE_TYPE             = var.MDSS_INSTANCE_TYPE
  VM_PWD                    = var.VM_PWD
  OFFER_PRODUCT             = var.OFFER_PRODUCT_MDSS
  SKU                       = var.SKU_MDSS
  SUBNET_ID                 = var.PUBLIC_ENVIRONMENT ? module.metadefender_network.PUB_SUBNET_ID : module.metadefender_network.PRIV_SUBNET_ID
  NSG_ID                    = module.metadefender_network.NSG_ID
  DEPLOY_MDSS_COSMOSDB      = var.DEPLOY_MDSS_COSMOSDB
  MDSS_COSMOSDB_ENDPOINT    = var.DEPLOY_MDSS_COSMOSDB ? module.metadefender_cosmosdb_mdss[0].cosmosdb_endpoint : ""
  depends_on = [module.metadefender_network,module.metadefender_resource_manager,module.metadefender_cosmosdb_mdss]
}