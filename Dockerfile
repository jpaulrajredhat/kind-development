FROM apache/airflow:2.9.3
RUN pip install apache-airflow-providers-trino
# FROM  quay.io/osclimate/airflow-2.7.3-omdingest-1.4.1:1.0