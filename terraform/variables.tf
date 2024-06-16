locals {
  data_lake_bucket = "coins_data_lake"
  all_project_services = concat(var.gcp_service_list, [
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
  ])
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

variable "gcp_storage_class" {
  description = "Storage class type for your bucket. Check official docs for more info."
  default = "STANDARD"
}

variable "staging_dataset_name" {
  description = "BigQuery Dataset that raw data (from GCS) will be written to"
  type = string
  default = "stg_coins_dataset"
}

variable "production_dataset_name" {
  description = "BigQuery Dataset that transformed data (from DBT) will be written to"
  type = string
  default = "prod_coins_dataset"
}

variable "instance_name" {
  type = string
  default = "cryptolytics-instance"
}

variable "machine_type" {
  type = string
  default = "e2-standard-4"
}

variable "zone" {
  description = "Region for VM"
  type = string
  default = "europe-west6-a"
}

variable "gce_ssh_user" {
  default = "aayomide"   # adjust to preference
}

variable "ssh_pub_key_file" {
  description = "Path to the generated SSH public key on your local machine"
  default = "C:/Users/pc/.ssh/ssh_key.pub"  # adjust accordingly
}

variable "ssh_priv_key_file" {
  description = "Path to the generated SSH private key on your local machine"
  default = "C:/Users/pc/.ssh/ssh_key"     # adjust accordingly
}

variable "gcp_service_list" {
  description = "The list of apis necessary for the project"
  type        = list(string)
  default     = ["storage.googleapis.com",]
}

variable "account_id" {
  description = "The service account ID."  # Changing this forces a new service account to be created."
  default =  "cypto-analytics-project-sa"
}

variable "description" {
  description = "Custom SA for VM instance." # Can be updated without creating a new resource
  default     = "managed-by-terraform"
}

variable "roles" {
  type        = list(string)
  description = "The roles that will be granted to the service account."
  default     = ["roles/owner","roles/storage.admin","roles/storage.objectAdmin","roles/bigquery.admin"]
}