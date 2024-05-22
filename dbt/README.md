## Data Transformation in DBT Cloud
### How to reproduce:
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

-----
### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
    - Generating a [custom dbt schema](https://docs.getdbt.com/docs/build/custom-schemas#understanding-custom-schemas)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [dbt community](https://getdbt.com/community) to learn from other analytics engineers
