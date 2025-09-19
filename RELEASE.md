# Release Management

This document describes the complete release process for the exe-sign Docker image and GitHub Action.

## Release Automation

The project uses GitHub Actions to automatically build and publish Docker images when releases are created.

### What Happens During Release

1. **Multi-Platform Build**: Docker images are built for both `linux/amd64` and `linux/arm64`
2. **Security Scanning**: Trivy scans the image for vulnerabilities
3. **Tag Management**: Multiple tags are created and published to Docker Hub
4. **Release Notes**: Automatic updates with Docker usage information

### Available Tags After Release

For a release `v1.2.3`, the following tags are created:

- `latest` - Always points to the newest release
- `v1.2.3` - Specific version tag
- `1` - Major version tag (updated for all 1.x.x releases)
- `1.2` - Minor version tag (updated for all 1.2.x releases)

## Creating a Release

### Prerequisites

1. Ensure all changes are merged to the main branch
2. Verify that the latest commit passes all CI checks
3. Update version-specific documentation if needed

### Step 1: Create a Git Tag

```bash
# Create and push a version tag
git tag v1.2.3
git push origin v1.2.3
```

### Step 2: Create GitHub Release

1. Go to the [Releases page](../../releases)
2. Click "Create a new release"
3. Fill in the release information:
   - **Tag version**: `v1.2.3` (use the tag you created)
   - **Release title**: `Version 1.2.3` or a descriptive title
   - **Description**: Changelog and notable changes

#### Example Release Description

```markdown
## What's Changed

### New Features
- Added support for new certificate formats
- Improved error handling and validation

### Bug Fixes
- Fixed certificate password validation
- Resolved Docker build issues

### Documentation
- Updated GitHub Actions integration guide
- Added troubleshooting section

## Docker Usage

This release is available on Docker Hub:

```bash
docker pull ricardopaes/exe-sign:v1.2.3
docker pull ricardopaes/exe-sign:latest
```

### Step 3: Monitor the Release Build

1. After creating the release, monitor the [Actions tab](../../actions)
2. The "Release" workflow will automatically start
3. Check for any build or security scan failures

## Release Workflow Details

### Automatic Tagging

The release workflow automatically creates multiple Docker tags:

- If releasing `v1.2.3`:
  - Creates `1.2.3`, `1.2`, `1`, and `latest` tags
  - Updates existing major/minor tags to point to the new version

### Security Scanning

Every release includes:
- Trivy vulnerability scanning
- SARIF results uploaded to GitHub Security tab
- Scan summary in the workflow output

### Build Platforms

Images are built for:
- `linux/amd64` (Intel/AMD 64-bit)
- `linux/arm64` (ARM 64-bit, including Apple Silicon)

## Release Notes Enhancement

The release workflow automatically adds Docker usage information to release notes:

```markdown
## Docker Usage

Pull this release:

```bash
docker pull ricardopaes/exe-sign:v1.2.3
docker pull ricardopaes/exe-sign:latest
```

### Available Tags

- `latest` - Latest stable release
- `v1.2.3` - This specific version
- `1` - Latest v1.x.x release
- `1.2` - Latest v1.2.x release

## Troubleshooting Releases

### Build Failures

If the release build fails:

1. Check the workflow logs in the Actions tab
2. Common issues:
   - Docker build context problems
   - Dependency installation failures
   - Security scan failures (high/critical vulnerabilities)

### Security Scan Failures

If Trivy finds high or critical vulnerabilities:

1. Review the security scan results
2. Update base image or dependencies
3. Create a patch release with fixes

### Docker Hub Authentication

If Docker push fails:

1. Verify `DOCKER_USERNAME` and `DOCKER_PASSWORD` secrets are set
2. Check Docker Hub token permissions
3. Ensure the repository exists on Docker Hub

## Manual Tag Builds

To trigger a build for an existing tag without creating a new release:

1. Go to the [Actions tab](../../actions)
2. Select "Build Tag" workflow
3. Click "Run workflow"
4. Enter the tag name (e.g., `v1.2.3`)

This is useful for:
- Rebuilding after fixing build issues
- Updating tags due to security fixes
- Testing the build process

## Version Numbering

Follow [Semantic Versioning](https://semver.org/):

- **Major** (X.0.0): Breaking changes
- **Minor** (X.Y.0): New features, backward compatible
- **Patch** (X.Y.Z): Bug fixes, backward compatible

### Examples

- `v1.0.0` - Initial release
- `v1.1.0` - Added new features
- `v1.1.1` - Bug fixes
- `v2.0.0` - Breaking changes

## GitHub Action Usage

Once released, other repositories can use this action:

### Latest Version (Recommended)

```yaml
uses: ricardoapaes/exe-sign@v1
```

### Specific Version

```yaml
uses: ricardoapaes/exe-sign@v1.0.0
```

### Main Branch (Not Recommended for Production)

```yaml
uses: ricardoapaes/exe-sign@main
```

## Best Practices

1. **Test Before Release**: Ensure all PR checks pass
2. **Clear Changelog**: Document what changed in the release
3. **Monitor Builds**: Watch the release workflow for issues
4. **Security First**: Address any critical vulnerabilities before release
5. **Consistent Tagging**: Always use `v` prefix for version tags

## Integration with Other Workflows

The release workflow integrates with:
- **PR Builds**: Same build process, different triggers
- **Security Scanning**: Consistent Trivy configuration
- **Cleanup**: PR images are cleaned up separately from release images

Release images (`latest`, version tags) are never automatically cleaned up.