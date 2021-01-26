# Executable Sign

Docker image to sign an executable using osslsigncode.

```docker
docker run -v ${PWD}/work/:/work/ likesistemas/exe-sign:latest
```

## Enviroment Variables

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