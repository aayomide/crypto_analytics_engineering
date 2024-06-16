from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator



# set default arguments
afw_default_args = {
    "owner": "airflow",
    "start_date": datetime(2024, 5, 25),
    "depends_on_past": False,
    "retries": 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    dag_id="transform_data_in_dbt_dag",
    # schedule_interval=timedelta(minutes=5),  # run every 5 minutes
    default_args= afw_default_args,
    max_active_runs=1,
    catchup = False,
    tags=['crypto-analytics-afw'],
) as dag:

    
    # navigate to the dbt directory and build the dbt models
    dbt_transformation_task = BashOperator(
        task_id = 'dbt_transform_data',
        bash_command = 'cd /opt/airflow/dbt && ls -a && dbt build --profiles-dir .',
    )
    
    

