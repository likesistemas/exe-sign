# Executable Sign

Docker image to sign an executable using osslsigncode.

## Quick Start

1. Copy the `.env.example` file to `.env` and configure your certificate password:

```bash
cp .env.example .env
# Edit the .env file and set CERT_PASSWORD with the correct password
```

2. Place your PFX certificate and executable file in the `work/` folder

3. Run using docker-compose:

```bash
docker-compose run sign-exe
```

Or using docker directly:

```bash
docker run -v ${PWD}/work/:/work/ -e CERT_PASSWORD=your_password likesistemas/exe-sign:latest
```

## GitHub Actions Usage

This repository provides GitHub Actions for signing executables in CI/CD pipelines.

### Using from Another Repository

You can use this action directly from other repositories:

```yaml
- name: Sign executable
  uses: likesistemas/exe-sign@v1
  with:
    executable-path: 'path/to/your/executable.exe'
    signed-executable-name: 'signed-executable.exe'
    certificate-base64: ${{ secrets.CERT_BASE64 }}
    certificate-password: ${{ secrets.CERT_PASSWORD }}
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
        uses: likesistemas/exe-sign@v1
        with:
          executable-path: 'dist/myapp.exe'
          signed-executable-name: 'myapp-signed.exe'
          certificate-base64: ${{ secrets.CERT_BASE64 }}
          certificate-password: ${{ secrets.CERT_PASSWORD }}

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
    certificate-base64: ${{ secrets.CERT_BASE64 }}
    certificate-password: ${{ secrets.CERT_PASSWORD }}
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
      CERT_PASSWORD: ${{ secrets.CERT_PASSWORD }}
      CERT_BASE64: ${{ secrets.CERT_BASE64 }}
      SIGNING_PASSWORD: ${{ secrets.SIGNING_PASSWORD }}
```

### Required Secrets

To use GitHub Actions signing, you need to set up these repository secrets:

1. **CERT_BASE64**: Your certificate file (.pfx) encoded in Base64
   ```bash
   # Convert your certificate to Base64
   cat certificate.pfx | base64 -w 0
   ```

2. **CERT_PASSWORD**: Password for your certificate file

3. **SIGNING_PASSWORD** (optional): Additional password for osslsigncode (defaults to 'like')

### Setting up Secrets

1. Go to your repository settings
2. Navigate to "Secrets and variables" → "Actions"
3. Click "New repository secret"
4. Add the required secrets listed above

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
docker pull likesistemas/exe-sign:pr-123  # Replace 123 with your PR number
```

See [PR_WORKFLOWS.md](PR_WORKFLOWS.md) for detailed information about PR testing workflows.

## Troubleshooting

### Error "Mac verify error: invalid password?"

This error indicates that the PFX certificate password is incorrect. To resolve:

1. Verify that the password is correct by testing the certificate:

```bash
openssl pkcs12 -info -in work/certificate.pfx -password pass:YOUR_PASSWORD -noout
```

2. Set the correct password in the `.env` file or in the `CERT_PASSWORD` environment variable

### Error "no start line" or "Failed to read private key"

These errors usually occur when:

- The certificate password is incorrect
- The PFX file is corrupted
- The certificate format is not valid

## Environment Variables

CERT_FILE: Certificate file that should be in the /work/ folder. Default: certificate.pfx

CERT_PASSWORD: Certificate password. Default: 123456

EXE_FILE: Executable to be signed. Default: app.exe

EXE_SIGNED: Final signed file name. Default: app_signed.exe

## Certificate (Taken from the [Source](https://stackoverflow.com/questions/252226/signing-a-windows-exe-file))

The first thing you have to do is get the certificate and install it on your computer, you can either buy one from a Certificate Authority or generate one using [makecert](https://docs.microsoft.com/en-us/powershell/module/pkiclient/new-selfsignedcertificate).

Here are the pros and cons of the 2 options

### Buy a certificate

#### Pros

Using a certificate issued by a CA(Certificate Authority) will ensure that Windows will not warn the end user about an application from an "unknown publisher" on any Computer using the certificate from the CA (OS normally comes with the root certificates from manny CA's)

#### Cons

There is a cost involved on getting a certificate from a CA

For prices, see [Cheapssl](https://cheapsslsecurity.com/sslproducts/codesigningcertificate.html) and [Digicert](https://www.digicert.com/code-signing/)

### Generate a certificate using Makecert

#### Pros

The steps are easy and you can share the certificate with the end users

#### Cons

End users will have to manually install the certificate on their machines and depending on your clients that might not be an option
Certificates generated with makecert are normally used for development and testing, not production.