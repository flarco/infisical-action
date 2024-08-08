FROM python:3

WORKDIR /

COPY entrypoint.sh /entrypoint.sh
COPY infisical-load.py /infisical-load.py

RUN apt-get update && \
    apt-get install -y --no-install-recommends jq && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/entrypoint.sh"]