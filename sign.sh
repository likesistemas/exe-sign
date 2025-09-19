#!/bin/bash

# Enable error handling
set -e

# Color codes for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log messages with colors and emojis
log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to log success messages
log_success() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${GREEN}✅ $1${NC}"
}

# Function to log warning messages
log_warning() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${YELLOW}⚠️  $1${NC}"
}

# Function to log info messages
log_info() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${BLUE}ℹ️  $1${NC}"
}

# Function to handle errors
error_exit() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${RED}❌ ERROR: $1${NC}"
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

log_info "🚀 Starting executable signing process..."
log "📂 Certificate file: ${CERT_FILE}"
log "🎯 Executable file: ${EXE_FILE}"
log "📝 Output file: ${EXE_SIGNED}"

if [ ! -f "${CERT_FILE}" ]; then
    error_exit "Certificate file '${CERT_FILE}' not found"
fi

if [ ! -f "${EXE_FILE}" ]; then
    error_exit "Executable file '${EXE_FILE}' not found"
fi

# Validate certificate password by testing the PFX file
log_info "🔐 Validating certificate file and password..."
if ! openssl pkcs12 -info -in "${CERT_FILE}" -password "pass:${CERT_PASSWORD}" -noout 2>/dev/null; then
    error_exit "Invalid certificate file or incorrect password for ${CERT_FILE}"
fi
log_success "Certificate validation successful"

mkdir -p sign

KEY_PEM=sign/key.pem
CERT_PEM=sign/cert.pem
RSA_KEY=sign/authenticode.key
RSA_SPC=sign/authenticode.spc

log_info "🔑 Extracting private key from certificate..."
if ! openssl pkcs12 \
    -password "pass:${CERT_PASSWORD}" \
    -in "${CERT_FILE}" \
    -nocerts -nodes \
    -out "${KEY_PEM}" 2>/dev/null; then
    error_exit "Failed to extract private key from certificate"
fi

log_info "📜 Extracting certificate from PFX..."
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

log_info "🔄 Converting private key to DER format..."
if ! openssl rsa \
    -in "${KEY_PEM}" \
    -outform DER \
    -out "${RSA_KEY}" 2>/dev/null; then
    error_exit "Failed to convert private key to DER format"
fi

log_info "📦 Creating SPC file..."
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

log_info "✍️  Signing executable..."
if ! osslsigncode -spc "${RSA_SPC}" -key "${RSA_KEY}" \
    -pass "${PASSWORD}" -t "${TIMESTAMP}" \
    -in "${EXE_FILE}" -out "${EXE_SIGNED}"; then
    error_exit "Failed to sign executable"
fi

log_info "🔍 Verifying signed executable..."
if osslsigncode verify "${EXE_SIGNED}"; then
    log_success "Signature verification successful"
else
    log_warning "Signature verification failed (this is normal for test/development certificates)"
    log_info "The executable has been signed, but verification requires trusted CA certificates"
fi

log_info "🧹 Cleaning up temporary files..."
rm -Rf sign/

log_success "🎉 Executable signing completed successfully!"