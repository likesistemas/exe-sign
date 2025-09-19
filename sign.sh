#!/bin/bash

# Enable error handling
set -e

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to handle errors
error_exit() {
    log "ERROR: $1"
    exit 1
}

if [ -n "${1}" ]; then
    EXE_FILE=${1}
fi

if [ -n "${2}" ]; then
    EXE_SIGNED=${2}
fi

if [ -n "${3}" ]; then
    PASSWORD=${3}
fi

log "Starting executable signing process..."
log "Certificate file: ${CERT_FILE}"
log "Executable file: ${EXE_FILE}"
log "Output file: ${EXE_SIGNED}"

if [ ! -f "${CERT_FILE}" ]; then
    error_exit "Certificate file '${CERT_FILE}' not found"
fi

if [ ! -f "${EXE_FILE}" ]; then
    error_exit "Executable file '${EXE_FILE}' not found"
fi

# Validate certificate password by testing the PFX file
log "Validating certificate file and password..."
if ! openssl pkcs12 -info -in "${CERT_FILE}" -password "pass:${CERT_PASSWORD}" -noout 2>/dev/null; then
    error_exit "Invalid certificate file or incorrect password for ${CERT_FILE}"
fi
log "Certificate validation successful"

mkdir -p sign

KEY_PEM=sign/key.pem
CERT_PEM=sign/cert.pem
RSA_KEY=sign/authenticode.key
RSA_SPC=sign/authenticode.spc

log "Extracting private key from certificate..."
if ! openssl pkcs12 \
    -password "pass:${CERT_PASSWORD}" \
    -in "${CERT_FILE}" \
    -nocerts -nodes \
    -out "${KEY_PEM}" 2>/dev/null; then
    error_exit "Failed to extract private key from certificate"
fi

log "Extracting certificate from PFX..."
if ! openssl pkcs12 \
    -password "pass:${CERT_PASSWORD}" \
    -in "${CERT_FILE}" \
    -nokeys -nodes \
    -out "${CERT_PEM}" 2>/dev/null; then
    error_exit "Failed to extract certificate from PFX"
fi

# Verify extracted files
if [ ! -f "${KEY_PEM}" ] || [ ! -s "${KEY_PEM}" ]; then
    error_exit "Private key extraction failed or file is empty"
fi

if [ ! -f "${CERT_PEM}" ] || [ ! -s "${CERT_PEM}" ]; then
    error_exit "Certificate extraction failed or file is empty"
fi

log "Converting private key to DER format..."
if ! openssl rsa \
    -in "${KEY_PEM}" \
    -outform DER \
    -out "${RSA_KEY}" 2>/dev/null; then
    error_exit "Failed to convert private key to DER format"
fi

log "Creating SPC file..."
if ! openssl crl2pkcs7 -nocrl -certfile "${CERT_PEM}" \
    -outform DER \
    -out "${RSA_SPC}" 2>/dev/null; then
    error_exit "Failed to create SPC file"
fi

# Verify created files
if [ ! -f "${RSA_KEY}" ] || [ ! -s "${RSA_KEY}" ]; then
    error_exit "RSA key file creation failed or file is empty"
fi

if [ ! -f "${RSA_SPC}" ] || [ ! -s "${RSA_SPC}" ]; then
    error_exit "SPC file creation failed or file is empty"
fi

log "Signing executable..."
if ! osslsigncode -spc "${RSA_SPC}" -key "${RSA_KEY}" \
    -pass "${PASSWORD}" -t "${TIMESTAMP}" \
    -in "${EXE_FILE}" -out "${EXE_SIGNED}"; then
    error_exit "Failed to sign executable"
fi

log "Verifying signed executable..."
if osslsigncode verify "${EXE_SIGNED}"; then
    log "Signature verification successful"
else
    log "WARNING: Signature verification failed (this is normal for test/development certificates)"
    log "The executable has been signed, but verification requires trusted CA certificates"
fi

log "Cleaning up temporary files..."
rm -Rf sign/

log "Executable signing completed successfully!"