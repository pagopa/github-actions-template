# payments-flow-docker-snapshot

Allows to build docker image with the follow tags:

- snapshot
- snapshot-(branch name)

and if runned manually, create a fake tag called `develop-snapshot` + the previous tag.

## how to use

- `github_pat`: allow to use your github pat, if not the repository default github token will be used

### Example

```yaml
name: 📦 Flow Snapshot Docker

on:
  push:
    branches-ignore:
      - 'develop'
      - 'uat'
      - 'main'
    paths-ignore:
      - 'CODEOWNERS'
      - '**.md'
      - '.**'
  workflow_dispatch:
    inputs:
      docker_build_enabled:
        description: 'Enable Docker build'
        required: false
        default: 'true'
      azdo_trigger_enabled:
        description: 'Enable Azure DevOps trigger'
        required: false
        default: 'true'
      deploy_aks_branch:
          description: 'argocd deploy aks branch name'
          required: false
          default: 'main'

env:
  # branch choosed by workflow_dispatch or by push event
  CURRENT_BRANCH: ${{ github.event.inputs.branch || github.ref_name }}

jobs:
  checkout:
    name: 🔖 Checkout Repository
    runs-on: ubuntu-22.04
    steps:
      - name: Checkout code
        uses: actions/checkout@eef61447b9ff4aafe5dcd4e0bbf5d482be7e7871
        with:
          ref: ${{ env.CURRENT_BRANCH }}

  docker-build:
    name: 📦 Docker Build and Push
    needs: checkout
    runs-on: ubuntu-22.04
    if: ${{ github.event_name == 'push' || github.event.inputs.docker_build_enabled == 'true' }}
    steps:
      - name: Checkout code
        uses: actions/checkout@eef61447b9ff4aafe5dcd4e0bbf5d482be7e7871
        with:
          ref: ${{ env.CURRENT_BRANCH }}
          
      - name: Run Snapshot Docker Build/Push
        uses: pagopa/github-actions-template/payments-flow-docker-snapshot@new-azdo-trigger-pipeline
        with:
          current_branch: ${{ github.ref_name }}
```
