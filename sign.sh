#!/bin/bash

if [ -n "${1}" ]; then
    EXE_FILE=${1}
fi

if [ -n "${2}" ]; then
    EXE_SIGNED=${2}
fi

if [ -n "${3}" ]; then
    PASSWORD=${3}
fi

if [ ! -f ${CERT_FILE} ]; then
    echo "Certificate ${CERT_FILE} file not found"
    exit
fi

if [ ! -f ${EXE_FILE} ]; then
    echo "Executable '${EXE_FILE}' not found"
    exit
fi

mkdir -p sign

KEY_PEM=sign/key.pem
CERT_PEM=sign/cert.pem
RSA_KEY=sign/authenticode.key
RSA_SPC=sign/authenticode.spc

openssl pkcs12 \
    -password pass:${CERT_PASSWORD} \
    -in ${CERT_FILE} \
    -nocerts -nodes \
    -out ${KEY_PEM}

openssl pkcs12 \
    -password pass:${CERT_PASSWORD} \
    -in ${CERT_FILE} \
    -nokeys -nodes \
    -out ${CERT_PEM}

openssl rsa \
    -in ${KEY_PEM} \
    -outform DER \
    -out ${RSA_KEY}

openssl crl2pkcs7 -nocrl -certfile ${CERT_PEM} \
    -outform DER \
    -out ${RSA_SPC}

osslsigncode -spc ${RSA_SPC} -key ${RSA_KEY} \
    -pass ${PASSWORD} -t ${TIMESTAMP} \
    -in ${EXE_FILE} -out ${EXE_SIGNED}

osslsigncode verify ${EXE_SIGNED}

rm -Rf sign/