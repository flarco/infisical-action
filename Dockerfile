FROM python:3

WORKDIR /

COPY entrypoint.sh /entrypoint.sh
COPY infisical-load.py /infisical-load.py

RUN INPUT_VERSION=${INFISICAL_VERSION:-latest} cd / && wget "https://github.com/Infisical/infisical/releases/download/infisical-cli%2Fv$INPUT_VERSION/infisical_$INPUT_VERSION_linux_amd64.tar.gz" && tar -xvf "infisical_$INPUT_VERSION_linux_amd64.tar.gz" && rm -f "infisical_$INPUT_VERSION_linux_amd64.tar.gz"

ENTRYPOINT ["/entrypoint.sh"]