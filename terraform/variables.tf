locals {
  data_lake_bucket = "coins_data_lake"
}

variable "project_id" {
  description = "Your GCP Project ID"
  type = string
}

variable "region" {
  description = "Regional location of GCP resources. Choose based on your location: https://cloud.google.com/about/locations"
  default = "europe-west6"
  type = string
}

variable "location" {
  description = "Project Location"
  default = "EU"
  type = string
}

variable "credentials" {
  description = "Path to GCP project service account json key"
}

variable "gcp_storage_class" {
  description = "Storage class type for your bucket. Check official docs for more info."
  default = "STANDARD"
}

variable "staging_dataset_name" {
  description = "BigQuery Dataset that raw data (from GCS) will be written to"
  type        = string
}

variable "production_dataset_name" {
  description = "BigQuery Dataset that transformed data (from DBT) will be written to"
  type        = string
}