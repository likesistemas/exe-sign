# Security Guidelines

## 🔒 Protecting Sensitive Data

This repository is designed to be publicly shared. Please follow these security guidelines:

### ❌ Never Commit These Files:

1. **Real certificates** (`.pfx`, `.p12` files)
   - Place certificates in the `work/` directory (automatically ignored by git)
   - Use dummy/test certificates for documentation only

2. **Real passwords** in `.env` file
   - The `.env` file is ignored by git
   - Set `CERTIFICATE_PASSWORD` to your actual certificate password locally
   - Use placeholder values in `.env.example`

3. **Docker Hub credentials**
   - Use GitHub Secrets for `DOCKER_USERNAME` and `DOCKER_PASSWORD`
   - Never hardcode credentials in workflow files

### ✅ Safe to Commit:

1. **Workflow files** that reference secrets via `${{ secrets.NAME }}`
2. **Documentation** with example usage
3. **Configuration templates** (like `.env.example`)
4. **Dummy/test files** for demonstration purposes

### 🛡️ Before Making Repository Public:

1. **Review commit history** for any accidentally committed sensitive data
2. **Verify `.gitignore`** properly excludes sensitive files
3. **Check workflows** use proper secret references
4. **Test with dummy data** to ensure functionality

### 🚨 If Sensitive Data Was Committed:

1. **Remove from git history** using `git filter-branch` or similar
2. **Revoke exposed credentials** immediately
3. **Generate new certificates/passwords**
4. **Update secrets** in GitHub repository settings

## Repository Security Features

- **Automatic `.gitignore`** for certificates and environment files
- **Secret-based authentication** for Docker Hub
- **No hardcoded credentials** in any files
- **Secure certificate handling** in GitHub Actions

Remember: Security is a shared responsibility. Always verify before committing!
