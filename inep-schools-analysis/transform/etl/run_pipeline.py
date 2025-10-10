import os
from pathlib import Path
from typing import Iterable, List

import papermill as pm
import psycopg2
from psycopg2 import sql
from pyspark.sql import SparkSession


PROJECT_ROOT = Path(
    os.getenv("PROJECT_ROOT", Path(__file__).resolve().parents[2])
).resolve()
NOTEBOOK_ARTIFACT_DIR = Path(
    os.getenv("PIPELINE_NOTEBOOK_OUTPUT_DIR", "/tmp/pipeline-notebooks")
)
NOTEBOOK_ARTIFACT_DIR.mkdir(parents=True, exist_ok=True)


def _resolve_path(path_str: str) -> Path:
    path = Path(path_str)
    if not path.is_absolute():
        path = (PROJECT_ROOT / path).resolve()
    return path


def _load_notebook_sequence() -> List[Path]:
    notebooks_env = os.getenv("PIPELINE_NOTEBOOKS")

    if notebooks_env:
        notebook_entries = [
            entry.strip() for entry in notebooks_env.split(",") if entry.strip()
        ]
    else:
        notebook_entries = [
            os.getenv("TRANSFORM_NOTEBOOK", "transform/tratamento.ipynb")
        ]

    notebooks: List[Path] = []
    for entry in notebook_entries:
        nb_path = _resolve_path(entry)
        if not nb_path.is_file():
            raise FileNotFoundError(f"Notebook not found: {nb_path}")
        notebooks.append(nb_path)

    return notebooks


def _execute_notebooks(notebooks: Iterable[Path]) -> None:
    for notebook_path in notebooks:
        print(f"Executing notebook: {notebook_path}")
        output_path = NOTEBOOK_ARTIFACT_DIR / f"{notebook_path.stem}-executed.ipynb"
        pm.execute_notebook(str(notebook_path), str(output_path))
        print(f"Notebook executed successfully: {notebook_path}")


# Database connection settings
db_user = os.getenv("POSTGRES_USER", "inep")
db_password = os.getenv("POSTGRES_PASSWORD", "inep")
db_name = os.getenv("POSTGRES_DB", "inep_db")
db_host = os.getenv("DB_HOST", os.getenv("POSTGRES_HOST", "db"))
db_port = os.getenv("DB_PORT", os.getenv("POSTGRES_PORT", "5432"))
db_url = f"jdbc:postgresql://{db_host}:{db_port}/{db_name}"
db_properties = {
    "user": db_user,
    "password": db_password,
    "driver": "org.postgresql.Driver",
}

silver_dataset_path = _resolve_path(
    os.getenv("SILVER_PARQUET_PATH", "processed/escolas_silver.parquet")
)
silver_dataset_path.parent.mkdir(parents=True, exist_ok=True)


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
notebooks_to_run = _load_notebook_sequence()
_execute_notebooks(notebooks_to_run)

# Load processed data and write to Postgres
print("Loading processed data to database...")
ensure_escolas_table()
spark = SparkSession.builder \
    .appName("ParquetToPostgres") \
    .config("spark.jars.packages", "org.postgresql:postgresql:42.2.25") \
    .getOrCreate()

df_silver = spark.read.parquet(str(silver_dataset_path))

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
