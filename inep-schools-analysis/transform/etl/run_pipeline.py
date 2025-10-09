import os

import papermill as pm
import psycopg2
from psycopg2 import sql
from pyspark.sql import SparkSession


# Database connection settings
db_user = os.getenv('POSTGRES_USER', 'inep')
db_password = os.getenv('POSTGRES_PASSWORD', 'inep')
db_name = os.getenv('POSTGRES_DB', 'inep_db')
db_host = os.getenv('DB_HOST', 'db')
db_port = os.getenv('DB_PORT', '5432')
db_url = f'jdbc:postgresql://{db_host}:{db_port}/{db_name}'
db_properties = {
    "user": db_user,
    "password": db_password,
    "driver": "org.postgresql.Driver"
}


def ensure_escolas_table():
    """Create the target table ahead of the Spark write to avoid connection errors in the logs."""
    columns = [
        ("codigo_inep", "TEXT"),
        ("nome_escola", "TEXT"),
        ("uf", "TEXT"),
        ("municipio", "TEXT"),
        ("regiao", "TEXT"),
        ("localizacao", "TEXT"),
        ("is_rural", "INTEGER"),
        ("dependencia_administrativa", "TEXT"),
        ("is_publica", "INTEGER"),
        ("porte_escola", "TEXT"),
        ("porte_numerico", "INTEGER"),
        ("etapas_modalidades", "TEXT"),
        ("num_etapas", "INTEGER"),
        ("latitude", "DOUBLE PRECISION"),
        ("longitude", "DOUBLE PRECISION"),
        ("restricao_atendimento", "TEXT")
    ]

    create_statement = sql.SQL("""
        CREATE TABLE IF NOT EXISTS {table} (
            {columns}
        )
    """).format(
        table=sql.Identifier("escolas"),
        columns=sql.SQL(", ").join(
            sql.SQL("{} {}").format(sql.Identifier(name), sql.SQL(dtype))
            for name, dtype in columns
        )
    )

    try:
        with psycopg2.connect(
            dbname=db_name,
            user=db_user,
            password=db_password,
            host=db_host,
            port=db_port
        ) as conn:
            with conn.cursor() as cur:
                cur.execute(create_statement)
            conn.commit()
        print("Ensured target table 'escolas' exists before loading data.")
    except Exception as exc:
        print(f"Warning: unable to ensure 'escolas' table exists ({exc}). Continuing with Spark load.")


# Execute notebooks
print("Executing ingestion notebook...")
pm.execute_notebook(
   'raw/ingestao.ipynb',
   '/dev/null'
)
print("Ingestion notebook executed.")

print("Executing processing notebook...")
pm.execute_notebook(
   'processed/tratamento.ipynb',
   '/dev/null'
)
print("Processing notebook executed.")

# Load processed data and write to Postgres
print("Loading processed data to database...")
ensure_escolas_table()
spark = SparkSession.builder \
    .appName("ParquetToPostgres") \
    .config("spark.jars.packages", "org.postgresql:postgresql:42.2.25") \
    .getOrCreate()

df_silver = spark.read.parquet('processed/escolas_silver.parquet')

# Overwrite will truncate the existing data while keeping the schema.
df_silver.write \
    .mode('overwrite') \
    .option("truncate", "true") \
    .jdbc(
        url=db_url,
        table='escolas',
        properties=db_properties
    )

print("Data loaded successfully to PostgreSQL.")
spark.stop()
