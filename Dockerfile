FROM python:3

WORKDIR /

COPY entrypoint.sh /entrypoint.sh
COPY infisical-load.py /infisical-load.py

ADD https://github.com/Infisical/infisical/releases/download/infisical-cli%2Fv${INPUT_VERSION}/infisical_${INPUT_VERSION}_linux_amd64.tar.gz /infisical.tar.gz


RUN cd / && tar -xvf infisical.tar.gz

ENTRYPOINT ["/entrypoint.sh"]