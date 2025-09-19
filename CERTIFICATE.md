# Certificate Setup Guide

This guide explains how to obtain and configure code signing certificates for use with exe-sign.

## 🔐 Types of Certificates

### Production Certificates (Recommended)

For applications that will be distributed to end users:

**Advantages:**

- ✅ No security warnings for end users
- ✅ Trusted by Windows by default
- ✅ Professional appearance
- ✅ Enhanced security

**Where to buy:**

- [DigiCert](https://www.digicert.com/code-signing/) - $474/year
- [Sectigo](https://sectigo.com/ssl-certificates-tls/code-signing) - $415/year  
- [GlobalSign](https://www.globalsign.com/code-signing-certificate) - $319/year
- [Cheap SSL Security](https://cheapsslsecurity.com/sslproducts/codesigningcertificate.html) - From $199/year

**Requirements:**

- Business verification process
- Valid business documents
- Identity verification
- Can take 1-7 business days to issue

### Development/Test Certificates

For development and testing purposes:

**Advantages:**

- ✅ Free to generate
- ✅ Immediate availability
- ✅ Good for testing signing workflows
- ✅ No business verification required

**Disadvantages:**

- ⚠️ Will show security warnings to end users
- ⚠️ Not trusted by Windows by default
- ⚠️ Users must manually trust the certificate

## 🛠️ Generating Test Certificates

### Using PowerShell (Windows)

```powershell
# Generate a self-signed certificate
$cert = New-SelfSignedCertificate -Subject "CN=YourCompany" -Type CodeSigning -KeySpec Signature -KeyLength 2048 -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -KeyExportPolicy Exportable -KeyUsage DigitalSignature -CertStoreLocation Cert:\CurrentUser\My

# Export to PFX file
$password = ConvertTo-SecureString -String "YourPassword123" -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath "certificate.pfx" -Password $password
```

### Using OpenSSL (Linux/macOS)

```bash
# Generate private key
openssl genrsa -out private.key 2048

# Generate certificate signing request
openssl req -new -key private.key -out certificate.csr -subj "/CN=YourCompany/O=Your Organization/C=US"

# Generate self-signed certificate
openssl x509 -req -days 365 -in certificate.csr -signkey private.key -out certificate.crt

# Create PFX file
openssl pkcs12 -export -out certificate.pfx -inkey private.key -in certificate.crt -password pass:YourPassword123
```

## 📁 File Setup

Once you have your certificate:

### For Local Development

#### Option 1: Using BASE64 environment variable (Recommended)

1. Encode your certificate to BASE64:

   ```bash
   # Linux/macOS
   export CERTIFICATE_BASE64=$(cat certificate.pfx | base64 -w 0)
   
   # Windows PowerShell
   $env:CERTIFICATE_BASE64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes("certificate.pfx"))
   ```

2. Set the password in `.env`:

   ```bash
   CERTIFICATE_PASSWORD=your_certificate_password
   ```

#### Option 2: Using file in work directory (Legacy)

1. Place your certificate in the `work/` directory:

   ```text
   work/certificate.pfx
   ```

   Note: When using BASE64 environment variable, the file in work/ directory is not needed.

### For GitHub Actions

1. Encode your certificate to Base64:

   ```bash
   # Linux/macOS
   cat certificate.pfx | base64 -w 0
   
   # Windows PowerShell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("certificate.pfx"))
   ```

2. Add GitHub Secrets:
   - `CERTIFICATE_BASE64`: The Base64 encoded certificate
   - `CERTIFICATE_PASSWORD`: Your certificate password

## 🔒 Security Best Practices

### For Production Certificates

1. **Store securely**: Keep original certificate files in secure, encrypted storage
2. **Backup properly**: Maintain secure backups of certificates and passwords
3. **Limit access**: Only authorized personnel should have access
4. **Monitor usage**: Track when and where certificates are used
5. **Rotate regularly**: Replace certificates before expiration

### For All Certificates

1. **Use strong passwords**: Minimum 12 characters with mixed case, numbers, symbols
2. **Never commit**: Never add certificates or passwords to version control
3. **Use secrets**: Always use GitHub Secrets for passwords and encoded certificates
4. **Clean up**: Remove temporary certificate files after use
5. **Audit access**: Regularly review who has access to certificate secrets

## 🚨 Troubleshooting

### "Mac verify error: invalid password?"

- Verify the password is correct
- Check that the certificate isn't corrupted
- Ensure the certificate format is PKCS#12 (.pfx)

### "Certificate not trusted" warnings

- Expected for self-signed certificates
- Users must manually trust the certificate
- Consider purchasing a commercial certificate for production

### Certificate expired

- Check certificate validity dates
- Renew certificate before expiration
- Update Base64 encoding after renewal

## 📞 Support

For certificate-related issues:

- Contact your Certificate Authority for commercial certificates
- Check OpenSSL documentation for self-signed certificates
- Review Windows documentation for certificate installation

For exe-sign specific issues:

- Check the main README.md troubleshooting section
- Review GitHub Actions logs for detailed error messages
- Ensure all secrets are properly configured
