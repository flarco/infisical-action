FROM python:3

WORKDIR /

COPY entrypoint.sh /entrypoint.sh
COPY infisical-load.py /infisical-load.py

ARG VERSION
ENV VERSION=$VERSION

RUN cd / && wget "https://github.com/Infisical/infisical/releases/download/infisical-cli%2Fv${VERSION}/infisical_${VERSION}_linux_amd64.tar.gz" && tar -xvf "infisical_${VERSION}_linux_amd64.tar.gz" && rm -f "infisical_${VERSION}_linux_amd64.tar.gz"


ENTRYPOINT ["/entrypoint.sh"]