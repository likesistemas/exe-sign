# Executable Sign

Docker image to sign an executable using osslsigncode.

## Quick Start

### Prerequisites

1. **Certificate**: You need a code signing certificate (.pfx file)
   - For production: Purchase from a Certificate Authority (CA)
   - For testing: Generate a self-signed certificate
   - See [📋 CERTIFICATE.md](CERTIFICATE.md) for detailed setup guide
2. **Password**: Password for your certificate

### Setup

1. Copy the `.env.example` file to `.env` and configure your certificate password:

```bash
cp .env.example .env
# Edit the .env file and set CERTIFICATE_PASSWORD with the correct password
```

2. Place your PFX certificate in the `work/` folder and name it `certificate.pfx`

3. Run using docker-compose:

```bash
docker-compose run sign-exe
```

Or using docker directly:

```bash
docker run -v ${PWD}/work/:/work/ -e CERTIFICATE_BASE64="$(cat certificate.pfx | base64 -w 0)" -e CERTIFICATE_PASSWORD=your_password ricardopaes/exe-sign:latest
```

## GitHub Actions Usage

This repository provides GitHub Actions for signing executables in CI/CD pipelines.

### Using from Another Repository

You can use this action directly from other repositories:

```yaml
- name: Sign executable
  uses: ricardoapaes/exe-sign@v1
  with:
    executable-path: 'path/to/your/executable.exe'
    signed-executable-name: 'signed-executable.exe'
    certificate-base64: ${{ secrets.CERTIFICATE_BASE64 }}
    certificate-password: ${{ secrets.CERTIFICATE_PASSWORD }}
    signing-password: ${{ secrets.SIGNING_PASSWORD }} # optional
```

### Complete Example for External Use

```yaml
name: Build and Sign Application

on:
  push:
    branches: [ main ]
  release:
    types: [ published ]

jobs:
  build-and-sign:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Build your application
        run: |
          # Your build steps here
          # This should produce an executable file

      - name: Sign executable
        id: sign
        uses: ricardoapaes/exe-sign@v1
        with:
          executable-path: 'dist/myapp.exe'
          signed-executable-name: 'myapp-signed.exe'
          certificate-base64: ${{ secrets.CERTIFICATE_BASE64 }}
          certificate-password: ${{ secrets.CERTIFICATE_PASSWORD }}

      - name: Upload signed executable
        uses: actions/upload-artifact@v4
        with:
          name: signed-executable
          path: ${{ steps.sign.outputs.signed-executable-path }}
```

### Using the Local Composite Action

```yaml
- name: Sign executable
  uses: ./.github/actions/sign-executable
  with:
    executable-path: 'path/to/your/executable.exe'
    signed-executable-name: 'signed-executable.exe'
    certificate-base64: ${{ secrets.CERTIFICATE_BASE64 }}
    certificate-password: ${{ secrets.CERTIFICATE_PASSWORD }}
    signing-password: ${{ secrets.SIGNING_PASSWORD }} # optional
```

### Using the Reusable Workflow

```yaml
name: Build and Sign

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build your application
        run: |
          # Your build steps here
          # This should produce an executable file
  
  sign:
    needs: build
    uses: ./.github/workflows/sign-executable.yml
    with:
      executable-path: 'dist/myapp.exe'
      signed-executable-name: 'myapp-signed.exe'
      upload-artifact: true
    secrets:
      CERTIFICATE_PASSWORD: ${{ secrets.CERTIFICATE_PASSWORD }}
      CERTIFICATE_BASE64: ${{ secrets.CERTIFICATE_BASE64 }}
      SIGNING_PASSWORD: ${{ secrets.SIGNING_PASSWORD }}
```

### Setting up Secrets for GitHub Actions

To use this action in other repositories, you need to configure these secrets:

1. **CERTIFICATE_BASE64**: Your certificate file (.pfx) encoded in Base64

   ```bash
   # Linux/macOS
   cat certificate.pfx | base64 -w 0
   
   # Windows PowerShell  
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("certificate.pfx"))
   ```

   ```bash
   # Linux/macOS
   cat your-certificate.pfx | base64 -w 0
   
   # Windows PowerShell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("your-certificate.pfx"))
   ```

2. **CERTIFICATE_PASSWORD**: Password for your certificate file

3. **SIGNING_PASSWORD** (optional): Additional password for osslsigncode (defaults to 'like')

### Setting up Secrets

1. Go to your repository settings
2. Navigate to "Secrets and variables" → "Actions"
3. Click "New repository secret"
4. Add the required secrets listed above

**⚠️ Security Note**: The certificate and passwords are stored securely as GitHub Secrets and are never exposed in logs or code.

## Pull Request Testing

When you open a pull request, an automated workflow will:

- Build a Docker image for your PR
- Push it to Docker Hub with tag `pr-{number}`
- Run security scans and basic tests
- Comment on the PR with testing instructions

When the PR is closed or merged, another workflow will:

- Automatically detect the PR closure
- Comment with cleanup instructions for the Docker images
- Provide direct links for manual image removal

You can test PR changes using:
```bash
docker pull ricardopaes/exe-sign:pr-123  # Replace 123 with your PR number
```

See [PR_WORKFLOWS.md](PR_WORKFLOWS.md) for detailed information about PR testing workflows.

## Docker Hub Images

This project automatically publishes Docker images to Docker Hub:

### Available Tags

- **`latest`**: Always points to the most recent release
- **`v{version}`**: Specific version tags (e.g., `v1.0.0`)
- **`{major}`**: Major version tags (e.g., `1`)
- **`{major}.{minor}`**: Minor version tags (e.g., `1.0`)
- **`pr-{number}`**: PR-specific tags for testing

### Using Different Tags

```bash
# Latest stable version
docker pull ricardopaes/exe-sign:latest

# Specific version
docker pull ricardopaes/exe-sign:v1.0.0

# Major version (gets updates for patches and minor versions)
docker pull ricardopaes/exe-sign:1

# PR testing
docker pull ricardopaes/exe-sign:pr-123
```

### Release Process

When a new release is created:

1. **Automatic Build**: Docker images are built for multiple platforms
2. **Security Scan**: Trivy scans for vulnerabilities
3. **Tag Management**: Multiple tags are created (`latest`, version-specific)
4. **Release Notes**: Docker usage information is added automatically

See [RELEASE.md](RELEASE.md) for detailed release instructions.

## Troubleshooting

### Error "Mac verify error: invalid password?"

This error indicates that the PFX certificate password is incorrect. To resolve:

1. Verify that the password is correct by testing the certificate:

```bash
openssl pkcs12 -info -in work/certificate.pfx -password pass:YOUR_PASSWORD -noout
```

1. Set the correct password in the `.env` file or in the `CERTIFICATE_PASSWORD` environment variable

### Error "no start line" or "Failed to read private key"

These errors usually occur when:

- The certificate password is incorrect
- The PFX file is corrupted
- The certificate format is not valid

## Environment Variables

CERTIFICATE_BASE64: Your certificate (.pfx) encoded as BASE64 string. Required

CERTIFICATE_PASSWORD: Certificate password. Required

EXE_FILE: Executable to be signed. Default: app.exe

EXE_SIGNED: Final signed file name. Default: app_signed.exe

## 📋 Certificate Guide

For detailed information about obtaining and configuring code signing certificates, see our comprehensive [Certificate Setup Guide](CERTIFICATE.md).

The guide covers:

- 🛒 Where to buy production certificates
- 🔨 How to generate test certificates
- 🔧 Local development setup
- ☁️ GitHub Actions configuration
- 🔒 Security best practices
- 🚨 Troubleshooting common issues

Quick links:

- **Need a certificate?** → [CERTIFICATE.md - Types of Certificates](CERTIFICATE.md#-types-of-certificates)
- **Setup for development?** → [CERTIFICATE.md - File Setup](CERTIFICATE.md#-file-setup)
- **Security questions?** → [CERTIFICATE.md - Security Best Practices](CERTIFICATE.md#-security-best-practices)
