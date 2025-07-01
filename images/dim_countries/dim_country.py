import requests
import pendulum
import os.path
import urllib.request
from sqlalchemy import create_engine, text

import boto3
import pandas as pd
from io import BytesIO
from zipfile import ZipFile
import pycountry


def load_data_to_s3_bucket():
    
    pycountry.countries.add_entry(alpha_3="ROW", alpha_2 = "", name="Rest of the World", numeric = "" )       
    df_country = pd.DataFrame([[country.alpha_3, country.alpha_2, country.name]  for country in pycountry.countries ], columns=['country_iso3_code', 'country_iso2_code', 'country_name'], dtype='string' )
    parquet_bytes = df_country.to_parquet(compression='gzip')  

    # Initialize the MinIO client using boto3
    s3_client = boto3.client(
        's3',
        endpoint_url='http://minio:9000',  # Replace with your MinIO server URL
        aws_access_key_id='minioAdmin',
        aws_secret_access_key='minio1234',
        region_name='us-east-1'  # Optional; can be None if MinIO doesn't require it
    )

    # Path to your local ZIP file containing Parquet files
    # zip_file_path = "https://zenodo.org/records/8159736/files/parquet-only.zip"
    data_stream = BytesIO(parquet_bytes)
    bucket_name = "pcaf"
    bucket_key = "raw/pycountry/pycountry.parquet"

    # Upload to MinIO
    s3_client.upload_fileobj(
        Fileobj=data_stream,
        Bucket=bucket_name,
        Key=bucket_key
    )
    print(f"Uploaded {bucket_key} to MinIO")
    print("Country files uploaded to minnio successfully.")

        
    
    host = "trino"
    port = 8081
    username = "admin"
    catalog = "hive"  # e.g., "hive"


    # Create the SQLAlchemy engine for Trino
    # engine = create_engine(f"trino://{username}@{host}:{port}/{catalog}/{schema}?protocol=https")
    engine = create_engine(f"trino://{username}@{host}:{port}/{catalog}/?protocol=http")
    print("trino connection success")
    # CREATE SCHEMA IF NOT EXISTS hive.pcaf WITH (location = 's3a://pcaf/data'
    # Create a schema (if needed)
    schema_name = "pcaf"
    location= "s3a://pcaf/data"

    create_schema_query = f"""CREATE SCHEMA IF NOT EXISTS {schema_name} WITH (location = '{location}')"""
    print("Initiated--2 ")
    
    with engine.connect() as connection:
        connection.execute(text(create_schema_query))

        print(f"Schema '{schema_name}' created with location '{location}' or already exists.")

    table_name = "pycountry"
    external_location = "s3a://pcaf/raw/pycountry/"
    
    sql_table =f"""CREATE TABLE IF NOT EXISTS {schema_name}.{table_name} (
                    "country_iso3_code" varchar, 
                    "country_iso2_code" varchar, 
                    "country_name" varchar
                    )
                    with (
                     external_location = '{external_location}',
                     format = 'PARQUET'
                    )"""
    
    with engine.connect() as connection:
        connection.execute(text(sql_table))
    
if __name__ == "__main__":
    load_data_to_s3_bucket()