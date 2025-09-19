# GitHub Actions Integration

This document provides detailed instructions for using the executable signing functionality in GitHub Actions workflows.

## Using from Another Repository

The easiest way to use this action is to reference it directly from other repositories:

```yaml
- name: Sign executable
  uses: likesistemas/exe-sign@v1
  with:
    executable-path: 'dist/myapp.exe'
    signed-executable-name: 'myapp-signed.exe'
    certificate-base64: ${{ secrets.CERT_BASE64 }}
    certificate-password: ${{ secrets.CERT_PASSWORD }}
```

## Setup

### 1. Prepare Your Certificate

First, you need to encode your certificate file (.pfx) to Base64:

```bash
# Linux/macOS
cat your-certificate.pfx | base64 -w 0

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("your-certificate.pfx"))
```

### 2. Configure Repository Secrets

Go to your repository settings and add these secrets:

- **CERT_BASE64**: The Base64 encoded certificate from step 1
- **CERT_PASSWORD**: The password for your certificate file
- **SIGNING_PASSWORD** (optional): Additional password for osslsigncode

### 3. Use in Your Workflow

#### Option A: Using the Composite Action (Recommended)

```yaml
- name: Sign executable
  uses: ./.github/actions/sign-executable
  with:
    executable-path: 'path/to/your/app.exe'
    signed-executable-name: 'signed-app.exe'
    certificate-base64: ${{ secrets.CERT_BASE64 }}
    certificate-password: ${{ secrets.CERT_PASSWORD }}
```

#### Option B: Using the Reusable Workflow

```yaml
jobs:
  sign:
    uses: ./.github/workflows/sign-executable.yml
    with:
      executable-path: 'dist/myapp.exe'
      signed-executable-name: 'myapp-signed.exe'
    secrets:
      CERT_PASSWORD: ${{ secrets.CERT_PASSWORD }}
      CERT_BASE64: ${{ secrets.CERT_BASE64 }}
```

## Complete Example

See `.github/workflows/example-build-and-sign.yml` for a complete workflow example that:

1. Builds an application
2. Signs the executable
3. Verifies the signature
4. Uploads the signed executable as an artifact

## Action Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `executable-path` | Path to the executable to sign | Yes | - |
| `signed-executable-name` | Name for the signed executable | No | `signed-executable.exe` |
| `certificate-base64` | Base64 encoded certificate | Yes | - |
| `certificate-password` | Certificate password | Yes | - |
| `signing-password` | Additional signing password | No | `like` |
| `timestamp-url` | Timestamp server URL | No | `http://timestamp.digicert.com` |

## Action Outputs

| Output | Description |
|--------|-------------|
| `signed-executable-path` | Path to the signed executable |

## Troubleshooting

### Common Issues

1. **Certificate decoding errors**: Ensure your Base64 encoding doesn't include line breaks
2. **File not found**: Check that the executable path is correct relative to the workspace
3. **Permission errors**: The action runs in Linux containers, ensure file permissions are correct

### Debug Mode

To enable verbose logging, add this step before signing:

```yaml
- name: Enable debug logging
  run: echo "ACTIONS_STEP_DEBUG=true" >> $GITHUB_ENV
```

## Security Considerations

- Certificate files are automatically cleaned up after signing
- Use repository secrets to store sensitive information
- Consider using environment-specific secrets for different deployment stages
- The signing process runs in isolated Docker containers

## Integration Examples

### With .NET Applications

```yaml
- name: Build .NET App
  run: dotnet publish -c Release -o dist/

- name: Sign executable
  uses: ./.github/actions/sign-executable
  with:
    executable-path: 'dist/YourApp.exe'
    signed-executable-name: 'YourApp-signed.exe'
    certificate-base64: ${{ secrets.CERT_BASE64 }}
    certificate-password: ${{ secrets.CERT_PASSWORD }}
```

### With Electron Applications

```yaml
- name: Build Electron App
  run: npm run build:win

- name: Sign executable
  uses: ./.github/actions/sign-executable
  with:
    executable-path: 'dist/win-unpacked/YourApp.exe'
    signed-executable-name: 'YourApp-signed.exe'
    certificate-base64: ${{ secrets.CERT_BASE64 }}
    certificate-password: ${{ secrets.CERT_PASSWORD }}
```

### With Release Creation

```yaml
- name: Sign executable
  id: sign
  uses: ./.github/actions/sign-executable
  with:
    executable-path: 'dist/app.exe'
    certificate-base64: ${{ secrets.CERT_BASE64 }}
    certificate-password: ${{ secrets.CERT_PASSWORD }}

- name: Create Release
  uses: actions/create-release@v1
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  with:
    tag_name: ${{ github.ref }}
    release_name: Release ${{ github.ref }}

- name: Upload Release Asset
  uses: actions/upload-release-asset@v1
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  with:
    upload_url: ${{ steps.create_release.outputs.upload_url }}
    asset_path: ${{ steps.sign.outputs.signed-executable-path }}
    asset_name: signed-app.exe
    asset_content_type: application/octet-stream
```