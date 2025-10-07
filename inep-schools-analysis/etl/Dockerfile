FROM apache/spark-py:v3.3.1

USER root

RUN apt-get update && \
    apt-get install -y git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY ./etl/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ./etl/run_pipeline.py .
COPY ./raw ./raw
COPY ./processed ./processed

CMD ["python3", "run_pipeline.py"]
