terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.19.0"
    }
  }
}

provider "google" {
  credentials = file(var.gcloud_json_key_path)

  project = var.project_id
  region  = var.MD_REGION
}