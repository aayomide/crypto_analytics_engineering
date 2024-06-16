## Terraform Setup
Terraform is used to provision and manage GCP resources for this project.

### Pre-requisites
Before you begin, ensure you have the following:
* Windows Subsystem for Linux (if you are running on Windows OS locally)
* A Google Cloud Platform (GCP) account and project ID
* The gcloud command-line tool installed and authenticated with your GCP project
* The Terraform CLI installed on your local machine. If not installed, follow [this installation guide.](https://phoenixnap.com/kb/how-to-install-terraform).

### Steps
* Clone this git repo to your local machine: `git clone https://github.com/aayomide/crypto_analytics_engineering.git`
* Navigate to the terraform folder inside the repo: `cd crypto_analytics_engineering/terraform`
* Modify the variables.tfvars file by replacing the placeholder values with your information:

    ~~~
        project_id = "<your-project-id>"
        region = "<region-you-want-the-vm-instance>"         #e.g "europe-west6"
        zone = "<zone-you-want-the-vm-instance>"            #e.g "europe-west6-a"

        gce_ssh_user = "<username-used-when-running-the-ssh-keygen-command>"   #e.g "aayomide"
        ssh_pub_key_file = "<path-to-your-ssh-public-key>"    #e.g "C:/Users/pc/.ssh/ssh_key.pub"
        ssh_priv_key_file = "<path-to-your-ssh-private-key>"   #e.g "C:/Users/pc/.ssh/ssh_key"

    ~~~

* Authenticate the Google SDK before initializing the infrastructure: `gcloud auth application-default login`
* Run the following commands to generate the necessary resources in GCP:
    * `terraform init` to initialize terraform and download the required dependencies.
    * `terraform plan -var-file variables.tfvars` to preview the changes that terraform will make to the GCP infrastructure.
    * `terraform apply -var-file variables.tfvars` to apply changes to the cloud, creating the GCS bucket and Big query datasets in GCP

----
Once successfully run, the following resources will be created on GCP:
* A virtual machine (including Ubuntu with SSH enabled, pre-installed Anaconda software, and a clone of this project repository)
* A data lake bucket in GCS
* Two BigQuery datasets
* A service account
* Enabled Google/IAM APIs
* An IAM member with roles: Owner, Storage Admin, Storage Object Admin, BigQuery Admin

Take note of the output in the terminal, particularly the external IP address (you can also find this information in the GCP Web UI).

> Note: When done with the entire project, you can run `terraform destroy -var-file variables.tfvars` to tear down all GCP resources created earlier to avoid costs on any running services.\
> However, if you wish to tear down the VM instance only, keep the data in the GCS bucket and Big Query, run `terraform destroy -var-file variables.tfvars --target google_compute_instance.vm_instance`
<br>

*In the terraform folder of this project, I followed Google's best practices for using terraform by minimizing the number of resources in each root module and modularizing the codes. This was inspired by [mrsvllmr's Terraform scripts.](https://github.com/mrsvllmr/de_zoomcamp_2023_project/tree/main/terraform)*