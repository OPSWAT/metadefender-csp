# General variables

RG_NAME                 = "metadefender" # Prefix to add to all the resources
MD_REGION               = "eastus" # Region for all the resources
MD_VNET_CIDR            = "192.168.0.0/16"  # VPC CIDR where to create the MetaDefender products
PUBLIC_ENVIRONMENT      = true
APIKEY_GENERATION       = true
IMPORT_RG               = false
VM_PWD                  = "<SET_UP_VM_PWD>"

# MetaDefender Core variables

DEPLOY_CORE             = true
CORE_INSTANCE_TYPE      = "Standard_D8s_v5"   # Instance type for MetaDefender Core
LICENSE_KEY_CORE        = ""
OFFER_PRODUCT_CORE      = "opswat-mdcore-linux"  # Windows opswat-mdcore-windows
SKU_CORE                = "opswat-mdcore-linux"  # Windows opswat-mdcore-windows

# MetaDefender ICAP variables

DEPLOY_ICAP             = false					# true to deploy ICAP together with Core
ICAP_INSTANCE_TYPE      = "Standard_D8s_v5"   # Instance type for MetaDefender Storage Security
LICENSE_KEY_ICAP        = ""
OFFER_PRODUCT_ICAP      = "opswat-metadefender-icap-server-linux"  # Windows opswat-icap-windows
SKU_ICAP                = "opswat-metadefender-icap-server-linux"  # Windows opswat-metadefender-icap-windows

# MetaDefender Storage Security variables

DEPLOY_MDSS             = false		          # true to deploy MetaDefender Storage Security together with Core
MDSS_INSTANCE_TYPE      = "Standard_D8s_v5"   # Instance type for MetaDefender Storage Security
OFFER_PRODUCT_MDSS      = "opswat-mdss-ubuntu"
SKU_MDSS                = "opswatmdssubuntu"
DEPLOY_MDSS_COSMOSDB     = false