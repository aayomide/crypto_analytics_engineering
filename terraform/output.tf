# ===============================================================================================================
# Output to the terminal: service account email and name, the external IP address (to be used to SSH to the VM)
# ==============================================================================================================

output "email" {
  value       = google_service_account.cryptolytics-sa.email
  description = "The e-mail address of the service account."
}

output "name" {
  value       = google_service_account.cryptolytics-sa.name
  description = "The service account name."
}

# private key
output "private_key" {
  value     = google_service_account_key.cryptolytics-sa-key.private_key
  description = "The private key of the service account in JSON format."
  sensitive = true
}

# Output a message guiding users on handling the private key securely
output "private_key_instructions" {
  value = "The private key has been saved to gcp_sa_key.json. Handle it securely."
}

output "decoded_private_key" {
  value     = base64decode(google_service_account_key.cryptolytics-sa-key.private_key)
  sensitive = true
}

# output the public ip address
output "instance_external_ip" {
    description = "External IP address of the instance"
    value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}