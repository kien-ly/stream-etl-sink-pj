"""DAG to trigger AWS Glue job daily."""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.amazon.aws.operators.glue import GlueJobOperator

default_args = {
    'owner': 'dt-team',
    'depends_on_past': False,
    'start_date': datetime(2025, 8, 14),
    'email_on_failure': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'glue_job_daily',
    default_args=default_args,
    description='Daily Glue Job Trigger',
    schedule_interval='0 2 * * *',  # 2 AM UTC = 9 AM Vietnam
    catchup=False,
    max_active_runs=1,
    tags=['glue', 'etl', 'daily'],
)

run_glue = GlueJobOperator(
    task_id='trigger_glue_job',
    job_name='YOUR_GLUE_JOB_NAME',  # Replace with actual job name
    aws_conn_id='aws_default',
    region_name='ap-southeast-1',
    wait_for_completion=True,
    dag=dag,
)