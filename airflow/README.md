## Developer guideline:
### How to set-up a local environment:
- Use uv to create a virtual environment and install the packages:
```
 uv venv --python 3.12
 uv sync
```
- For a quick setup, you can use the SequentialExecutor with Sqlite db. We will use a temporary folder to store airflow metadata:
```
-> mkdir -p /tmp/local_airflow
```
- Set needed environment variables, these one are used to config airflow regarding to our local environment.
```
export AIRFLOW_ENV=local
export AIRFLOW_HOME=/tmp/local_airflow

export AIRFLOW__CORE__LOAD_EXAMPLES=False
export AIRFLOW__CORE__DAGS_FOLDER=$(pwd)/dags
export AIRFLOW__CORE__PLUGINS_FOLDER=$(pwd)/operators
export AIRFLOW__WEBSERVER__ACCESS_LOGFILE=$AIRFLOW_HOME/webserver.log
export AIRFLOW__CORE__EXECUTOR=SequentialExecutor
export AIRFLOW__CORE__DEFAULT_TIMEZONE=Asia/Saigon
export AIRFLOW__CORE__CHECK_SLAS=True
export SQLALCHEMY_SILENCE_UBER_WARNING=1

```
- Use this command to start a standalone server:
```
airflow standalone
```
- Or, test a dag is serializeable:
```
airflow dags reserialize -S <your dag file path>
```
- Or run a dag locally for testing:
```
airflow dags test <your dag id>
```

- or run with Docker
```
docker build -t aismd-airflow:latest .
docker run -it --rm \
  --name airflow-local \
  -p 8080:8080 \
  -e AIRFLOW_ENV=local \
  -e AIRFLOW__CORE__LOAD_EXAMPLES=False \
  -e AIRFLOW__CORE__EXECUTOR=SequentialExecutor \
  -e AIRFLOW__CORE__DEFAULT_TIMEZONE=Asia/Saigon \
  -e AIRFLOW__CORE__CHECK_SLAS=True \
  -e SQLALCHEMY_SILENCE_UBER_WARNING=1 \
  aismd-airflow:latest \
  airflow standalone
```

- or run with docker-compose
```sh
docker-compose up
```
