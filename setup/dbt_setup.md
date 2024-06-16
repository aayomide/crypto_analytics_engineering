## Data Transformation in DBT CLI/Core
DBT was used to perform SQL transformations on our data, including changing column data types and renaming the columns. Additionally, the large staging table was split into fact and dimension tables as part of the data modeling process.

### Setup
* Navigate to the `dbt` folder inside the project repo: `cd crypto_analytics_engineering/dbt`
* Edit the `profile.yml` file to specify your GCP project id and save
* Also, navigate to the staging files directory: `cd crypto_analytics_engineering/dbt/models/staging` and edit the `source.yml` file to specify your GCP project id as the BigQuery databse name


### Notes on running DBT inside Airflow
In this project, the DBT job was configured to run within Airflow, allowing Airflow to orchestrate the entire extraction, loading, and transformation process. However, the DBT transformation job could also be separated from the extraction and loading, as DBT Cloud can schedule models and tests, execute them in the correct order, and send notifications upon failure, all without Airflow.

In practice, [a better approach](https://discourse.getdbt.com/t/what-is-the-best-practice-for-deploying-airflow-together-with-dbt/1926/2) might involve first dockerizing the DBT transformations and pushing the image to a container registry such as Google Artifact Registry. Then, the KubernetesPodOperator in Airflow can pull the image and run the dockerized transformations. This method resolves dependency conflicts, isolates the code, and modularizes the infrastructure components. For more details on this approach, you can read the full article [here](https://www.data-max.io/post/dbt-gcp-composer-airflow-docker).

-----
### Resources:
- Generating a [custom dbt schema](https://docs.getdbt.com/docs/build/custom-schemas#understanding-custom-schemas). How to Change the Default Dataset Name Created by DBT in BigQuery from dbt_{user_name} to a Custom Name.
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction) or take a [dbt course.](https://courses.getdbt.com/courses/)
