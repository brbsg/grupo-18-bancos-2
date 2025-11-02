import os
from pathlib import Path
from typing import Iterable, List

import papermill as pm
import psycopg2
from psycopg2 import sql


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
            os.getenv("TRANSFORM_NOTEBOOK", "transformer/tratamento.ipynb")
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

# Execute notebooks
notebooks_to_run = _load_notebook_sequence()
_execute_notebooks(notebooks_to_run)
