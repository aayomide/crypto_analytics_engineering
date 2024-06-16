import os
import json
import pandas as pd
from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

from google.cloud import storage
from airflow.providers.google.cloud.operators.bigquery import BigQueryCreateEmptyTableOperator
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator

import pyarrow as pa
import pyarrow.parquet as pq


# environmental variables
PROJECT_ID = os.environ.get("GCP_PROJECT_ID")
BUCKET_NAME = os.environ.get("GCP_GCS_BUCKET")
BQ_DATASET_NAME = os.environ.get("BQ_DATASET_NAME", 'stg_coins_dataset')
BQ_TABLE_NAME = "coins_data_raw"
path_to_local_home = os.environ.get("AIRFLOW_HOME", "/opt/airflow/")

dataset_url = "https://api.coincap.io/v2/assets?limit=2000"
dataset_file = "coins_{{ data_interval_end.strftime(\'%m%d_%H%M\') }}.json"
parquet_filename = dataset_file.replace('.json', '.parquet')


def format_to_parquet(src_file):
    """
    Convert the downloaded json dataset to parquet file format
    :param src_file: JSON file
    :return: parquet file
    """
    with open(src_file, 'r') as d:
        json_data = json.load(d)   # open the json file

    df = pd.DataFrame.from_dict(json_data['data'])   # extract needed object and convert to pandas dataframe
    
    table = pa.Table.from_pandas(df, preserve_index=False)
    pq.write_table(table, src_file.replace('.json', '.parquet'))  # export the parquet table to a parquet file


def upload_to_gcs(bucket_name, local_json_file):
    """
    Upload the local files to GCS
    Ref: https://cloud.google.com/storage/docs/uploading-objects#storage-upload-object-python
    
    :param bucket: GCS bucket name
    :param local_file: source path & file-name
    :return:
    """
    with open(local_json_file, 'r') as f:
        data = json.load(f)   # open the json file
    
    # extract coin data timestamp
    timestamp = data["timestamp"]
    created_datetime = datetime.fromtimestamp(timestamp/1000).strftime('%m%d_%H%M')  #format data as MonthDay_HourMinute e.g 0401_1230
    
    # create a client for gcs
    client = storage.Client()
    bucket = client.bucket(bucket_name)

    # upload data
    object_name = f"raw/parquet/coins_{created_datetime}.parquet"
    blob = bucket.blob(object_name)
    blob.upload_from_filename(local_json_file.replace('.json', '.parquet'), timeout=300)


# set default arguments
afw_default_args = {
    "owner": "airflow",
    "start_date": datetime(2024, 5, 25),
    "depends_on_past": False,
    "retries": 1,
    'retry_delay': timedelta(minutes=5),
}


# DAG declaration - using a Context Manager (an implicit way)
with DAG(
    dag_id="ingest_data_dag",
    schedule_interval=timedelta(minutes=5),  # run every 5 minutes
    default_args= afw_default_args,
    max_active_runs=1,
    catchup = False,
    tags=['crypto-analytics-afw'],
) as dag:

    # download the raw data
    download_data_task = BashOperator(
        task_id="download_data",
        bash_command = f'curl --location {dataset_url} > {path_to_local_home}/{dataset_file} && ls {path_to_local_home}'
    )

    # format the json file to parquet to make it easier to create the big query table schema
    format_to_parquet_task = PythonOperator(
        task_id="format_to_parquet",
        python_callable=format_to_parquet,
        op_kwargs={
            "src_file": f"{path_to_local_home}/{dataset_file}",
        },
    )

    # upload the raw data to gcs
    local_to_gcs_task = PythonOperator(
        task_id="local_to_gcs",
        python_callable=upload_to_gcs,
        op_kwargs={
            "bucket_name": BUCKET_NAME,
            "local_json_file": f"{path_to_local_home}/{dataset_file}",
        },
    )

    # # create a table in the big query dataset, if it doesnt already exist
    # create_bq_table_task = BigQueryCreateEmptyTableOperator(
    #     task_id="create_bq_table",
    #     dataset_id=BQ_DATASET_NAME,
    #     table_id=BQ_TABLE_NAME,
    # )


    # load the parquet file stored in gcs into the bq table
    load_data_to_bq_task = GCSToBigQueryOperator(
        task_id='load_data_to_bq',
        bucket=BUCKET_NAME,
        source_objects= [f"raw/parquet/{parquet_filename}"],
        source_format='PARQUET',
        destination_project_dataset_table=f'{PROJECT_ID}.{BQ_DATASET_NAME}.{BQ_TABLE_NAME}',
        autodetect=True,
        write_disposition='WRITE_TRUNCATE',
        create_disposition='CREATE_IF_NEEDED',
    )

    # trigger dbt data transformation task
    trigger_dbt_dag_task = TriggerDagRunOperator(
        task_id ='trigger_dbt_dag',
        trigger_dag_id = 'transform_data_in_dbt_dag', # id of the dag to trigger in transform.py
        # wait_for_completion = True
    )

    # remove the downloaded json file and csv file from airflow local path
    remove_local_files_task = BashOperator(
        task_id="remove_local_files",
        bash_command = f'ls {path_to_local_home} && rm -f {path_to_local_home}/{dataset_file} {path_to_local_home}/{parquet_filename}\
             && ls {path_to_local_home}'
    )


    # task dependencies
    download_data_task >> format_to_parquet_task >> local_to_gcs_task >> load_data_to_bq_task >> trigger_dbt_dag_task >> remove_local_files_task
    
    

