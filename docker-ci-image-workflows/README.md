
# Docker CI build

This repository contains reusable GitHub Actions located in `./global/docker-golden-image-workflows` that implement a docker build system with pr test image.

## 🏗️ Architecture

The workflows follow a strict promotion workflow:

```
PR Build → MA (Main)
   ↓          ↓ 
pr-*      ma-* 
```

## 📦 Available Composite Actions

These actions are designed to be used as steps within your own jobs.

1. **build-pr** - Builds Docker images for pull requests.
2. **build-and-promote-ma** - Builds golden images on main merge.

## 🚀 Usage in Your Repository (using Composite Actions)

Composite actions are more flexible as they allow you to define your own jobs and runners.

### Example: `.github/workflows/ci-cd.yml`

```yaml
jobs:
  pr-build:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: YOUR-ORG/REPO-NAME/global/docker-golden-image-workflows/build-pr@main
        with:
          registry_password: ${{ secrets.GITHUB_TOKEN }}

  main-build:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: YOUR-ORG/REPO-NAME/global/docker-golden-image-workflows/build-and-promote-ma@main
        with:
          registry_password: ${{ secrets.GITHUB_TOKEN }}
```




### Step 2: Configure Repository Settings

1. **Enable GitHub Packages**
   - Go to repository Settings → Packages
   - Ensure package visibility is set appropriately

2. **Set Up Production Approval** (Optional)
   - Go to Settings → Environments
   - Create environment: `production-approval`
   - Enable "Required reviewers"
   - Add reviewers who can approve production deployments

3. **Configure Secrets** (if using private registry)
   - Go to Settings → Secrets and variables → Actions
   - Add `REGISTRY_USERNAME` and `REGISTRY_PASSWORD` if not using GHCR

## 🔧 Configuration Options

### Common Inputs

All actions support these inputs:

| Input | Description | Default | Required |
|-------|-------------|---------|----------|
| `dockerfile_path` | Path to Dockerfile | `./Dockerfile` | No |
| `docker_context` | Docker build context | `.` | No |
| `registry` | Container registry URL | `ghcr.io` | No |
| `image_name` | Image name | Repository name | No |
| `build_args` | Build arguments (comma-separated) | `''` | No |
| `platforms` | Target platforms | `linux/amd64` | No |

### Build Arguments Example

```yaml
with:
  build_args: 'NODE_ENV=production,API_VERSION=v1,BUILD_DATE=2024-01-15'
```

### Multi-Platform Builds

```yaml
with:
  platforms: 'linux/amd64,linux/arm64'
```

### Custom Registry

```yaml
with:
  registry: 'docker.io'
  image_name: 'myorg/myapp'
secrets:
  registry_username: ${{ secrets.DOCKER_USERNAME }}
  registry_password: ${{ secrets.DOCKER_PASSWORD }}
```

## 🏷️ Tagging Strategy

### PR Images
- `pr-{number}` - PR number reference
- `pr-{branch}-{sha}` - Branch and commit reference

### MA (Main) Images
- `v{version}` - Semantic version (e.g., v0.1.2) [Primary]
- `latest` - Latest build on main
- `ma-latest` - Latest MA build (alias)
- `ma-{sha}` - Commit SHA reference
- `ma-{timestamp}` - Timestamped version (YYYYMMDD-HHmmss)

## 📊 Action Outputs

### build-and-promote-ma
- `image-digest` - SHA256 digest of the built image
- `image-tag` - Primary tag applied to the image
- `full-image` - Complete image reference with digest
- `version` - Version tag (e.g., v0.1.2) used for GitHub Release

## 🔐 Security Best Practices

1. **Use GitHub Environments** for approval gates
2. **Restrict workflow permissions** to minimum required
3. **Enable branch protection** on main branch
4. **Use CODEOWNERS** for workflow file changes
5. **Audit promotion manifests** regularly
6. **Use image digests** for production deployments

## 🎯 Example: Complete Deployment Flow

```bash
# 1. Developer creates PR
git checkout -b feature/new-feature
git push origin feature/new-feature
# → PR workflow builds pr-123 image

# 2. PR merged to main
git checkout main
git merge feature/new-feature
git push origin main
# → Main workflow builds v0.1.2 and latest
```

## 🆘 Troubleshooting

### Image not found
- Verify the tag exists in GitHub Container Registry
- Check workflow logs for build failures
- Ensure GITHUB_TOKEN has package write permissions

### Approval not working
- Verify environment is configured correctly
- Check required reviewers are set
- Ensure reviewers have appropriate permissions

## 📝 Versioning

This actions repository follows semantic versioning. Use specific versions in production:

```yaml
uses: YOUR-ORG/REPO-NAME/global/docker-golden-image-workflows/build-and-promote-ma@v1.0.0
```
