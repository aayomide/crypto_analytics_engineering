# ==========================================================================================================================
# Data Lake Bucket
# Ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
# ==========================================================================================================================

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