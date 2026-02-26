
# Example: Simple Application CI/CD

This example shows how to use the golden image workflows in a single, unified CI/CD pipeline.

## Features

- **Automatic PR builds** when pull requests are created
- **Automatic MA builds** when code is merged to main
- 
## Usage

### Automatic Builds

1. **Create a PR** - Automatically builds `pr-*` images
2. **Merge to main** - Automatically builds `ma-*` images

### Manual Actions

Go to **Actions** → **CI/CD Pipeline** → **Run workflow**

## Setup

1. Copy this workflow to your repository:
   ```bash
   mkdir -p .github/workflows
   cp examples/simple-app/.github/workflows/ci-cd.yml .github/workflows/
   ```

2. Update the workflow to reference your golden-image-workflows repository:
   ```yaml
   uses: pagopa/REPO/.github/workflows/docker-build-pr.yml@main
   ```

3. Configure production approval environment (optional):
   - Settings → Environments → New environment
   - Name: `production-approval`
   - Add required reviewers

4. Commit and push:
   ```bash
   git add .github/workflows/ci-cd.yml
   git commit -m "Add CI/CD pipeline"
   git push
   ```

## Workflow Diagram

```
┌─────────────┐
│   PR Open   │──→ Build pr-* image
└─────────────┘

┌─────────────┐
│ Merge Main  │──→ Build ma-* image
└─────────────┘
```
