# Cryptolytics: A Near-Real-Time Cryptocurrencies Analytics Dashboard

Cryptolytics presents a dashboard that consolidates and displays near-real-time* and historical performance data of 1000+ cryptocurrencies, organized by their rank. It aims to assist users in gaining insights into cryptocurrency market trends, enabling them to make informed decisions.

> **near-real-time because the data is loaded from the source and transformed every 5 minutes rather than instantly.*

## Project Description
Inefficient data processing pipelines often hinder timely and accurate analysis of cryptocurrency market trends. This project addresses the need for a streamlined and automated solution to gather, transform, and analyze cryptocurrency data from various sources. By leveraging modern tools such as Apache Airflow, DBT, Google BigQuery, and Looker Studio, the aim is to create an efficient and scalable data engineering workflow that enables seamless extraction, transformation, loading, and visualization of cryptocurrency market data, ultimately facilitating informed decision-making in the volatile and rapidly evolving cryptocurrency landscape.


## Dataset
This data used in this project was obtained from the [CoinCap API](https://docs.coincap.io/#51da64d7-b83b-4fac-824f-3f06b6c8d944), which provides real-time pricing and market activity for over 1,000 cryptocurrencies.

## Tools & Technologies used:
* Cloud: Google Cloud Platform
* Infrastructure as Code (Iac): Terraform
* Containerization: Docker, Docker Compose
* Workflow Orchestration: Apache Airflow
* Data Lake: Google Cloud Storage
* Data Warehouse: Big Query
* Data Transformation: Data Build Tool (DBT)
* Visualization: Looker Studio
* Programming Language: Python (batch processing), SQL (data transformation)

## Data Architecture

<div style="text-align: center;">
  <img src="images/1_data_architecture.gif" alt="full data pipeline" />
</div><br/>

Summary of the project map:
1. Automated infrastructure provisioning in GCP via Terraform 
2. Download of data from the CoinCap API, storage on Google Cloud Storage (GCS) and loading of the data into Google Bigquery via Python (orchestrated by Airflow)
3. DBT is then used to transform the raw data (stg_coindata dataset) on Bigquery, before sending this transformed data (located in the prod_coins_dataset) back to bigquery.
4. The transformed dataset is then used to create an analytical report on Lookstudio

---

## Reproducing the Data Pipeline 
In this section, we'll talk about how to recreate and run this data pipeline. 

> Note, this project was developed in Windows OS. Any other OS might require an alternative approach.

### 1. Setting up Google Cloud Platform (GCP)
To set up GCP for this project, please follow the steps below:

1. If you don't have a GCP account already, create a free trial account by following the steps [in this guide](https://www.googleadservices.com/pagead/aclk?sa=L&ai=DChcSEwjJ46z7nYv-AhURpLIKHROYA1EYABAAGgJscg&ohost=www.google.com&cid=CAASJeRojfEdEgjhUdavw-D6EgMxjah19w2TX2qQ3r70Et_NIAuN_L0&sig=AOD64_3k4xtbQ41NOlfBdXDrxSAO3RdG-A&q&adurl&ved=2ahUKEwiG6aT7nYv-AhX9QvEDHZlUD0gQ0Qx6BAgKEAE).

2. Create a new project on GCP (steps can be found [in this doc](https://cloud.google.com/resource-manager/docs/creating-managing-projects)) and take note of your Project ID as this information will be needed at the later stages of the project.

3. Create and configure a service account ( [guide](https://github.com/AliaHa3/data-engineering-zoomcamp-project/blob/main/setup/gcp_account.md#create-service-account)) to get access to the gcp project locally. Check the service account has all the permissions listed below:
   * Viewer
   * Storage Admin
   * Storage Object Admin
   * BigQuery Admin 

4. Generate and download the auth-keys (.json) for the newly created service account. In order to do this on GCP, 
    * Navigate to `IAM & Admin -> Service accounts`, select the newly created service account, then
    * Navigate to `KEYS -> ADD KEY -> Create new key -> JSON -> Create`.

5. Enable the following APIs for the project under the APIs & Services section on GCP :
   * [Identity and Access Management (IAM) API](https://console.cloud.google.com/apis/library/iam.googleapis.com)
   * [IAM service account credentials API](https://console.cloud.google.com/apis/library/iamcredentials.googleapis.com)
   * [Compute Engine API](https://console.developers.google.com/apis/api/compute.googleapis.com) (if you are going to use a VM instance)

6. If you haven't already, download and install the Google [SDK](https://cloud.google.com/sdk) for local setup. You can follow [this installation guide](https://github.com/DataTalksClub/data-engineering-zoomcamp/blob/main/01-docker-terraform/1_terraform_gcp/windows.md).
    * You might need to restart your system before gcloud can be used via CLI. Check if the installation was successful by running `gcloud -v` in your terminal to view the version of the gcloud installed
    * Authenticate the Google SDK by running the following code in your computer terminal:


        ` export GOOGLE_APPLICATION_CREDENTIALS="<path/to/your/service-account-keys>.json" `

        `gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS`
        
        `gcloud auth application-default login`



### 2. Terraform
Terraform was used to automate the provisioning of GCP resources. Below are instructions on how to setup a GCS bucket and a Big Query Dataset via Terraform.

### Pre-requisites
Before you begin, you will need to have the following:
* Windows sub-system Linux if you are running on local
* A Google Cloud Platform (GCP) account and project id
* The `gcloud` command-line tool installed and authenticated with your GCP project
* The Terraform CLI is installed on your local machine. If not installed, follow [this installation guide](https://phoenixnap.com/kb/how-to-install-terraform).

### Steps
* Clone this git repo to your local machine.
* Navigate to the "terraform" folder, using the bash command `cd` and create a ".keys" folder
* Copy the service account JSON credential file from earlier into this "terraform/.keys" folder and rename json file "gcp_sa_key.json"
* Still in the `terraform` folder, modify the `variables.tfvars` file by replacing the variable values below with yours:

    ~~~

        project_id = "your-gcp-project-id"
        region = "your-gcs-bucket-region"
        location = "your-gcs-bucket-location"
        credentials = "path-to-your-service-account-keys"
        staging_dataset_name = "your-bigquery-staging-dataset-name"
        production_dataset_name = "your-bigquery-production-dataset-name"

    ~~~

* In the CLI, before initializing the infrastructure, it is important to run: `gcloud auth application-default login` to authenticate the Google SDK.
* Still in the `terraform` folder, run the following commands to generate the needed resources inside the GCP:
    * Run `terraform init` to initialize terraform and download the required dependencies.
    * Run `terraform plan -var-file variables.tfvars` to preview the changes that terraform will make to the GCP infrastructure.
    * Run `terraform apply -var-file variables.tfvars` to apply changes to the cloud, creating the GCS bucket and Big query datasets in GCP

<!-- > Important to note that these resources are created in the europe-west6 zone. Down the line, the GCP resource location and DBT location have to match. -->

> Note: When done with the entire project, you can run `terraform destroy` to tear down all GCP resources created earlier, to avoid costs on any running services.


### 4. Airflow
Airflow was used to automate the data extraction process from the source and its transfer to the cloud storage bucket and data warehouse. Before running the DAG, you'll need to make sure you have the following dependencies installed:
* Google Cloud SDK (refer to [secion 1. above](#1-setting-up-google-cloud-platform-gcp) for setup instructions)
* Docker and Docker Compose.
* Airflow
    * For steps on how to install airflow effortlessly, follow this data zoomcamp [airflow installation guide](https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/cohorts/2022/week_2_data_ingestion/airflow#setup---custom-no-frills-version-lightweight)

After installation: In the terminal, 
* cd to the `airflow` folder of this project (I assume you cloned it to your local machine already). 
* Create a `.env` file to specify the GCP project id and bucket name variable to match the name of the GCP bucket where you want to store the data. The `.env` file should have the following content
        

    ~~~

        AIRFLOW_UID=500000
        GCP_PROJECT_ID= <your-project-id>
        GCP_GCS_BUCKET= <your-gcs-bucket-name>

    ~~~      

* Next, run the following docker commands in the CLI:
    * `docker-compose build` to build the Airflow Docker image 
    * `docker-compose up airflow-init` to initialize the Airflow scheduler, database, etc.
    * `docker-compose up` to start all airflow services from the containers 

This will start the Airflow services and begin running the `ingest_data.py` script every 5 minutes.

To view the Airflow web UI, open a browser and go to [http://localhost:8080/](http://localhost:8080/), the username and password are **airflow** in both cases. From there, you can see the status of the DAG and its tasks.

You can also start the DAG manually by clicking the "Trigger DAG" button on the DAG's page in the Airflow web UI.

> Note, when done with the orchestration, run the `docker-compose down` command to shut down the airflow container.

<!-- `docker stop $(docker ps -a -q)` to stop all running containers -->
<!-- `docker rm $(docker ps -a -q)` to remove all running containers -->


### 8. Data Transformation in DBT (data build tool) Cloud
You'll need a DBT (data build tool) account to follow these steps. If you don't have one yet, sign up [here](https://www.getdbt.com/signup/).

1. Once you're signed up, create a new project, select the BigQuery data warehouse connection, and upload your service account JSON file.
2. Click "Test Connection" to make sure dbt Cloud can access your BigQuery account.
3. Connect to a managed github repo. In the DBT develop tab, you can connect to the dbt project in [this repo](https://github.com/aayomide/crypto_analytics_engineering/tree/main/dbt). Then, click save.
    * **Note:** Make sure to choose the same location (in my case, europe-west-6) in dbt and BigQuery. If the locations don't match, dbt won't be able to find BigQuery.
4. Next, set up the "Production" deployment environment.
   * In DBT cloud, go to Deploy -> Environments -> Create Environment.
   * Name the environment "Production"
   * Set the dataset to "crypto_analytics" and save.
5. Next, navigate to Deploy -> Jobs -> Create Job
   * Choose the production environment you just created and make sure the following commands are listed under execution settings. If they're not, add them:
      * `dbt build`
      * `dbt run`
   * Save the job
6. Go to Deploy -> Jobs, select the job you just created, and run it ("Run Now").
7. When the job runs successfully, you'll see the following tables/views created in BigQuery under the "prod_coins_dataset" dataset:
   * `facts_coins` table
   * `dim_coins` table
   * `stg_coinsdata` view


### 9. Looker Studio
You can make use of any data visualization tool of your choice to access the data in the newly created table. In this case, Looker Studio was used, and set up to access the "prod_coins_dataset" dataset in Big Query.


<div style="text-align: center;">
  <img src="images/5_dashboard.png" alt="dashboard" />
  <p>
    <a href="https://lookerstudio.google.com/reporting/70e4d913-0ff9-4dee-b544-fcd8795a7770">Go to Dashboard</a>
  </p>
</div>

### 10. Further Improvements
* Use Terraform to configure more resources (e.g enable the APIs and spin a VM instance) in the Google Cloud
* Use Apache Kafka to stream the data
* Spin a VM cluster to run the airflow jobs in the cloud
* Write more robust data quality tests in DBT
* Perform advanced data transformation by using DBT or even use Spark for the transformation

### 11.  Reference
- [DataTalks.Club](https://datatalks.club/blog/data-engineering-zoomcamp.html) 
- [Data Engineering Zoomcamp](https://github.com/DataTalksClub/data-engineering-zoomcamp)

<!-- Resources:
- Pictures for Architecture: https://www.svgrepo.com/vectors/google-cloud/
- Remove image background with: https://www.remove.bg/ -->