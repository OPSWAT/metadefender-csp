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
NUMBER_INSTANCES_CORE   = 2

# MetaDefender ICAP variables

DEPLOY_ICAP             = true					# true to deploy ICAP together with Core
ICAP_INSTANCE_TYPE      = "Standard_D8s_v5"   # Instance type for MetaDefender Storage Security
LICENSE_KEY_ICAP        = ""
OFFER_PRODUCT_ICAP      = "opswat-metadefender-icap-server-linux"  # Windows opswat-icap-windows
SKU_ICAP                = "opswat-metadefender-icap-server-linux"  # Windows opswat-metadefender-icap-windows
NUMBER_INSTANCES_ICAP   = 2