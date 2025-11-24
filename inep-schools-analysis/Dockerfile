FROM apache/spark-py:v3.3.1

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY transformer/etl/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

COPY Transformer/etl /app

ENV PROJECT_ROOT=/app

CMD ["python3", "/app/transformer/etl/run_pipeline.py"]
