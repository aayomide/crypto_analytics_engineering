# ======================================================================================================
# BigQuery
# Ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset
# ======================================================================================================

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
