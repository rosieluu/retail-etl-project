terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  credentials = file("${path.module}/ext3rncrm-35be48d2e75c.json")
  project     = "ext3rncrm"
  region      = "europe-west1"
}