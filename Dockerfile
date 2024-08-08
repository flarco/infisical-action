FROM python:3

WORKDIR /

COPY entrypoint.sh /entrypoint.sh
COPY infisical-set-project-id.py /infisical-set-project-id.py
COPY infisical-load.py /infisical-load.py

ENTRYPOINT ["/entrypoint.sh"]