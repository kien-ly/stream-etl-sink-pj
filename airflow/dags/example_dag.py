"""DAG to trigger AWS Glue job daily at 10 AM."""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.amazon.aws.operators.glue import GlueJobOperator
from airflow.operators.dummy import DummyOperator

default_args = {
    'owner': 'dt-team',
    'depends_on_past': False,
    'start_date': datetime(2025, 8, 14),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'dt_glue_job_dag',
    default_args=default_args,
    description='Trigger AWS Glue job daily at 2 AM UTC - 9 AM Vietnam time',
    schedule_interval='0 2 * * *',
    catchup=False,
    tags=['glue', 'dt', 'etl'],
)

start = DummyOperator(
    task_id='start',
    dag=dag,
)

glue_job = GlueJobOperator(
    task_id='run_glue_job',
    job_name='your-glue-job-name',
    script_location='s3://your-bucket/scripts/your-script.py',
    s3_bucket='your-bucket',
    iam_role_name='your-glue-role',
    dag=dag,
)

end = DummyOperator(
    task_id='end',
    dag=dag,
)

start >> glue_job >> end