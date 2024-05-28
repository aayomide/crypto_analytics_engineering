terraform {
  required_version = ">= 1.0"
  backend "local" {}              # Can change from "local" to "gcs" (for google) or "s3" (for aws), if you would like to preserve your tf-state online
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.10.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  credentials = file(var.credentials)   # Use this if you do not want to set env-var GOOGLE_APPLICATION_CREDENTIALS
}

// create GCS bucket
resource "google_storage_bucket" "data-lake-bucket" {
  name          = "${local.data_lake_bucket}_${var.project_id}"     # Concatenating DL bucket & Project name for unique naming
  location      = var.region
  force_destroy = true
  storage_class = var.gcp_storage_class

  uniform_bucket_level_access = true

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30 # days
    }
  }
}

// create BQ dataset for the raw data
resource "google_bigquery_dataset" "stg_coins_dataset" {
  dataset_id                 = var.staging_dataset_name
  project                    = var.project_id
  location                   = var.region
  delete_contents_on_destroy = true
}

// create BQ dataset for the DBT-transformed data
resource "google_bigquery_dataset" "prod_coins_dataset" {
  dataset_id                 = var.production_dataset_name
  project                    = var.project_id
  location                   = var.region
  delete_contents_on_destroy = true
}
