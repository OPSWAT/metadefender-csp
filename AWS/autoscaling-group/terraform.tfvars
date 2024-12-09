# General variables

MD_ENV_NAME                 = "metadefender"
MD_REGION                   = "eu-central-1"
#ACCESS_KEY_ID              = "<ACCESS_KEY_ID>"
#SECRET_ACCESS_KEY          = "<SECRET_ACCESS_KEY>"
MD_VPC_CIDR                 = "192.168.0.0/16"
PUBLIC_ENVIRONMENT          = true
WARM_POOL_ENABLED           = true
APIKEY_GENERATION           = true
LICENSE_AUTOMATION_LAMBDA   = true

# MetaDefender Core variables

DEPLOY_CORE             = true
CORE_PRODUCT_ID 	    = "ani6v4vb5z4t87cymrfg3m451" # For Windows it is "9s8powksm1cj7fuafdnv0sfj9"
CORE_INSTANCE_TYPE      = "c5.2xlarge"
LICENSE_KEY_CORE        = ""
CORE_PWD                = ""
CORE_PORT               = 8008


# MetaDefender ICAP variables

DEPLOY_ICAP             = true
ICAP_PRODUCT_ID         = "b1w10ei2pw2vgpdsjw44pbffr" # For Windows it is 
ICAP_PORT               = 8048
ICAP_INSTANCE_TYPE      = "c5.2xlarge"
ICAP_PWD                = ""
LICENSE_KEY_ICAP        = ""
