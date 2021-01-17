# Executable Sign

Docker image to sign an executable using osslsigncode.

```docker
docker run -v ${PWD}/work/:/work/ likesistemas/exe-sign:latest
```

## Enviroment Variables

CERT_FILE: Certificate file that should be in the / work / folder. Default: certificate.pfx
CERT_PASSWORD: Certificate password. Default: 123456
EXE_FILE: Executable to be signed. Default: app.exe
EXE_SIGNED: Final signed file name. Default: app_signed.exe