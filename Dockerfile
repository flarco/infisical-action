FROM python:3

WORKDIR /

COPY entrypoint.sh /entrypoint.sh
COPY infisical-load.py /infisical-load.py


ENV INFISICAL_VERSION=${INFISICAL_VERSION}
ADD https://github.com/Infisical/infisical/releases/download/infisical-cli%2Fv${INFISICAL_VERSION}/infisical_${INFISICAL_VERSION}_linux_amd64.tar.gz /infisical.tar.gz


RUN cd / && tar -xvf infisical.tar.gz

ENTRYPOINT ["/entrypoint.sh"]