terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  credentials = file("${path.module}/votre-cle-service-account.json")
  project     = "ext3rncrm"
  region      = "europe-west1"
}