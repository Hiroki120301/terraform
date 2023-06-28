terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file("credentials.json")

  project = "terraform-on-gcp-hiroki"
  region  = "us-central1"
  zone    = "us-centrals1-c"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}