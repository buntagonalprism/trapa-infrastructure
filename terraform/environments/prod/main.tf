terraform {
  backend "gcs" {
    bucket = "terraform.trapa-prod.buntagon.com"
    prefix = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.84.0"
    }
  }
}

provider "google" {
  project = "trapa-prod"
  region  = "australia-southeast1"
}

module "common" {
  source      = "../../modules/common"
  projectName = "trapa-prod"
  location    = "australia-southeast1"
}
