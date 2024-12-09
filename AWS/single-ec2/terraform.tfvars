# General variables

MD_ENV_NAME             = "metadefender" # Prefix to add to all the resources
MD_REGION               = "eu-central-1" # Region for all the resources
EC2_KEY_NAME            = "" # Key pair to attach to EC2 instances (Optional)
#ACCESS_KEY_ID          = "<ACCESS_KEY_ID>"
#SECRET_ACCESS_KEY      = "<SECRET_ACCESS_KEY>"  # To give access to terraform (Optional, can use other ways to authenticate)
PUBLIC_ENVIRONMENT      = true
APIKEY_GENERATION       = true

# MetaDefender Core variables

DEPLOY_CORE             = true
MD_VPC_CIDR             = "192.168.0.0/16"  # VPC CIDR where to create the MetaDefender products
CORE_PRODUCT_ID 	    = "ani6v4vb5z4t87cymrfg3m451" #MetaDefender Core ID in AWS Marketplace || For Windows it is "9s8powksm1cj7fuafdnv0sfj9"
CORE_INSTANCE_TYPE      = "c5.2xlarge"   # Instance type for MetaDefender Core
LICENSE_KEY_CORE        = ""

# MetaDefender ICAP variables

DEPLOY_ICAP             = false					# true to deploy ICAP together with Core
ICAP_PRODUCT_ID         = "b1w10ei2pw2vgpdsjw44pbffr" #MetaDefender ICAP LINUX ID in AWS Marketplace  
ICAP_INSTANCE_TYPE      = "c5.2xlarge"   # Instance type for MetaDefender Storage Security
LICENSE_KEY_ICAP        = ""

# MetaDefender Storage Security variables

DEPLOY_MDSS             = false		# true to deploy MetaDefender Storage Security together with Core
MDSS_PRODUCT_ID         = "3mup1qubt6hwmup405eljau0k" # MetaDefender Storage Security LINUX ID in AWS Marketplace  
MDSS_INSTANCE_TYPE      = "c5.2xlarge"   # Instance type for MetaDefender Storage Security

DEPLOY_MDSS_DOCUMENTDB  = false  # true to deploy  MetaDefender Storage Security with a managed instance of Amazon DocumentDB
MDSS_DOCUMENTDB_INSTANCE_CLASS = "db.r5.large"
DEPLOY_MDSS_ELASTICACHE = false  # true to deploy  MetaDefender Storage Security with a managed instance of Elasticache Redis
MDSS_ELASTICACHE_NODE_TYPE = "cache.m5.large"
