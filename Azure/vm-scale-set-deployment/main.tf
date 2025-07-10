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
  LICENSE_AUTOMATION_FUNCTION      = var.LICENSE_AUTOMATION_FUNCTION
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
  LICENSE_KEY               = var.LICENSE_AUTOMATION_FUNCTION ? "" : var.LICENSE_KEY_CORE
  APIKEY                    = var.LICENSE_AUTOMATION_FUNCTION ? "" : var.LICENSE_KEY_CORE != "" && var.APIKEY_GENERATION ? random_bytes.apikey[0].hex : ""
  DEPLOY_CORE               = var.DEPLOY_CORE
  INSTANCE_TYPE             = var.CORE_INSTANCE_TYPE
  VM_PWD                    = var.VM_PWD
  OFFER_PRODUCT             = var.OFFER_PRODUCT_CORE
  SKU                       = var.SKU_CORE
  SUBNET_ID                 = module.metadefender_network.PRIV_SUBNET_ID
  APPGW_SUBNET_ID           = module.metadefender_network.APPGW_SUBNET_ID
  NSG_ID                    = module.metadefender_network.NSG_ID
  AUTOSCALING               = true
  NUMBER_INSTANCES          = var.NUMBER_INSTANCES_CORE

  depends_on = [module.metadefender_network,random_bytes.apikey,module.metadefender_resource_manager]
}

# Metadefender Core License Function handler

module "metadefender_licensing_handler_core" {
  source = "../azure-terraform-modules/licensing-handler-core"
  count             = var.DEPLOY_CORE && var.LICENSE_AUTOMATION_FUNCTION ? 1 :0
  ENV_NAME          = var.RG_NAME
  APP_NAME          = "core"
  RG_NAME           = module.metadefender_resource_manager.RG_NAME
  RG_ID             = module.metadefender_resource_manager.RG_ID
  VMSS_ID           = module.metadefender_computing_core[0].VMSS_ID
  SUBNET_ID         = module.metadefender_network.FUNC_SUBNET_ID
  LOCATION          = var.MD_REGION
  LICENSE_KEY       = var.LICENSE_KEY_CORE
  APIKEY            = var.APIKEY
  CORE_USER         = var.CORE_USER
  CORE_PWD          = var.CORE_PWD

  depends_on = [module.metadefender_network,random_bytes.apikey,module.metadefender_computing_core]
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
  LICENSE_AUTOMATION_FUNCTION = var.LICENSE_AUTOMATION_FUNCTION
  DEPLOY_ICAP               = var.DEPLOY_ICAP
  INSTANCE_TYPE             = var.ICAP_INSTANCE_TYPE
  VM_PWD                    = var.VM_PWD
  OFFER_PRODUCT             = var.OFFER_PRODUCT_ICAP
  SKU                       = var.SKU_ICAP
  SUBNET_ID                 = module.metadefender_network.PRIV_SUBNET_ID
  APPGW_SUBNET_ID           = module.metadefender_network.APPGW_SUBNET_ID
  NSG_ID                    = module.metadefender_network.NSG_ID
  AUTOSCALING               = true
  NUMBER_INSTANCES          = var.NUMBER_INSTANCES_ICAP


  depends_on = [module.metadefender_network,random_bytes.apikey,module.metadefender_resource_manager]
}
