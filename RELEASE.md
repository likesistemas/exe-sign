# Release Instructions

This document explains how to create releases for this GitHub Action so it can be used by other repositories.

## Creating a Release

### 1. Tag the Release

```bash
# Create and push a tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# Create major version tag for easier referencing
git tag -a v1 -m "Release v1"
git push origin v1
```

### 2. Create GitHub Release

1. Go to the repository's releases page
2. Click "Create a new release"
3. Choose the tag you just created
4. Add release notes describing changes
5. Publish the release

## Usage by Other Repositories

Once released, other repositories can use this action:

### Latest Version (Recommended)

```yaml
uses: likesistemas/exe-sign@v1
```

### Specific Version

```yaml
uses: likesistemas/exe-sign@v1.0.0
```

### Main Branch (Not Recommended for Production)

```yaml
uses: likesistemas/exe-sign@main
```

## Version Management

### Major Versions (v1, v2, etc.)

- For breaking changes
- Update the major version tag when making breaking changes
- Users can pin to major version for automatic updates

### Minor/Patch Versions (v1.1.0, v1.0.1, etc.)

- For new features and bug fixes
- Always backward compatible within the same major version
- Create specific tags for each release

## Example Release Workflow

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Create Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          draft: false
          prerelease: false
```

## Testing Before Release

Before creating a release, test the action:

```yaml
# In a test workflow
- name: Test action
  uses: ./
  with:
    executable-path: 'test/sample.exe'
    certificate-base64: ${{ secrets.TEST_CERT_BASE64 }}
    certificate-password: ${{ secrets.TEST_CERT_PASSWORD }}
```