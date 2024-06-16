# Base image
FROM apache/airflow:2.7.1

ENV AIRFLOW_HOME=/opt/airflow

# Switch to the airflow user
USER airflow

# Upgrade pip
RUN pip install --upgrade pip

# Copy the requirements file into the container and package dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt


# Add dbt to PATH
ENV PATH="/root/.local/bin:${PATH}"

SHELL ["/bin/bash", "-o", "pipefail", "-e", "-u", "-x", "-c"]

WORKDIR $AIRFLOW_HOME

COPY scripts scripts

USER $AIRFLOW_UID
