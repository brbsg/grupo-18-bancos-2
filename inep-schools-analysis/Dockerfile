FROM apache/spark-py:v3.3.1

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

COPY run_pipeline.py /app/run_pipeline.py

ENV PROJECT_ROOT=/app

CMD ["python3", "/app/run_pipeline.py"]
