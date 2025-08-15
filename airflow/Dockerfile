ARG AIRFLOW_VERSION=2.10.5
FROM apache/airflow:${AIRFLOW_VERSION}

# Create airflow group and user matching Bitnami's defaults
USER root

# Set working directory
WORKDIR /opt/airflow

# Copy project files
COPY . .
USER airflow
# Install uv and ensure pip is up to date
RUN pip install --upgrade pip \
    && pip install uv

# Create a virtual environment using system python3 interpreter
RUN uv venv --python python3 /opt/airflow/venv

# Prepend venv bin to PATH so uv, pip, and python are used
ENV PATH="/opt/airflow/venv/bin:${PATH}"

# Install package into venv
RUN uv pip install -e . --no-cache

# Configure Airflow DAGs folder
#ENV AIRFLOW__CORE__DAGS_FOLDER=/opt/airflow/dags/repo/aisdph_airflow_data/dags
 
