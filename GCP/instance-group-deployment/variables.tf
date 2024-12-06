  variable "project_id" {
    description = "GCloud project id"
    default = ""
  }
  
  variable "gcloud_json_key_path" {
    description = "JSON key with the credentials for the service account to use"
    default = "/path/to/json"
    type    = string
  }

  variable "MD_ENV_NAME" {
    type    = string
    default = "metadefender-test"
  }

  variable "MD_REGION" {
    type    = string
    default = "us-central1"
  }

  variable "MD_VPC_CIDR" {
    type = string
    default = "192.168.0.0/16"
  }
  variable "CORE_INSTANCE_TYPE" {
    type    = string
    default = ""
  }

  variable "LICENSE_KEY_CORE" {
    type = string
    default = ""
  }
  variable "DEPLOY_ICAP" {
    type = bool
    default = false
  }

  variable "ICAP_INSTANCE_TYPE" {
    type    = string
    default = ""
  }

  variable "LICENSE_KEY_ICAP" {
    type = string
    default = ""
  }
