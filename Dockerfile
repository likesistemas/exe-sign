FROM debian:13-slim as sign

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    osslsigncode openssl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work/

ENV CERT_FILE=certificate.pfx
ENV CERT_PASSWORD=123456
ENV EXE_FILE=app.exe
ENV EXE_SIGNED=app_signed.exe
ENV PASSWORD=like
ENV TIMESTAMP=http://timestamp.digicert.com

COPY sign.sh /usr/local/bin/sign
RUN chmod +x /usr/local/bin/sign

COPY work/certificate.pfx .

ENTRYPOINT [ "sign" ]