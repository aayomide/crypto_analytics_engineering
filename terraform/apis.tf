# =====================================================
# Enable the necessary GCP API services
# =====================================================
resource "google_project_service" "enabled_apis" {
  project  = var.project_id
  for_each = toset(local.all_project_services)
  service  = each.key

  disable_on_destroy = false
}