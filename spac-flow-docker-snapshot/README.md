# spac-flow-docker-snapshot

Allows to build docker image with the follow tags:

- snapshot
- snapshot-(branch name)

and if runned manually, create a fake tag called `develop-snapshot`

## how to use

```yaml
name: SPAC Snapshot docker build and push

on:
  push:
    branches-ignore:
      - 'main'
    paths-ignore:
      - 'CODEOWNERS'
      - '**.md'
      - '.**'
  workflow_dispatch:

env:
  CURRENT_BRANCH: ${{ github.event.inputs.branch || github.ref_name }}

jobs:
  spac-flow-docker-snapshot:
    runs-on: ubuntu-22.04
    environment: dev
    steps:
      - name: 🔖 Checkout code
        # https://github.com/actions/checkout/releases/tag/v4.2.1
        uses: actions/checkout@eef61447b9ff4aafe5dcd4e0bbf5d482be7e7871
        with:
          ref: ${{ env.CURRENT_BRANCH }}

      - name: 📦 Run Snapshot Docker Build/Push & Trigger
        uses: pagopa/github-actions-template/spac-flow-docker-snapshot@spac-flow-docker-snapshot
        with:
          current_branch: ${{ github.ref_name }}
          enable_azure_devops_step: 'true'
          azure_devops_apps: "[one-color]"
          azure_devops_project_url: 'https://dev.azure.com/pagopaspa/devopslab-projects'
          azure_devops_pipeline_name: 'devopslab-diego-deploy.deploy'
          azure_devops_pat: ${{ secrets.AZUREDEVOPS_PAT }}
```
