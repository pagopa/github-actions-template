# payments-flow-release

Allows to make a release and build docker image with the follow tags:

- develop-vX.Y.Z
- uat-vX.Y.Z
- vX.Y.Z

## how to use

```yaml
name: 🚀 Payments release

on:
  push:
    branches:
      - develop
      - uat
      - main
    paths-ignore:
      - 'CODEOWNERS'
      - '**.md'
      - '.**'
  workflow_dispatch:

jobs:
  payments-flow-release:
    runs-on: ubuntu-22.04
    environment: dev
    steps:
      - name: 🔖 Checkout code
        # https://github.com/actions/checkout/releases/tag/v4.2.1
        uses: actions/checkout@eef61447b9ff4aafe5dcd4e0bbf5d482be7e7871
        with:
          ref: ${{ github.ref_name }}

      - name: 🚀 release + docker + azdo
        # https://github.com/pagopa/github-actions-template/releases/tag/v1.16.0
        uses: pagopa/github-actions-template/payments-flow-release@payments-release
        with:
          current_branch: ${{ github.ref_name }}
          enable_azure_devops_step: 'true'
          azure_devops_project_url: 'https://dev.azure.com/pagopaspa/devopslab-projects'
          azure_devops_pipeline_name: 'devopslab-diego-deploy.deploy'
          azure_devops_pat: ${{ secrets.AZUREDEVOPS_PAT }}
          azure_template_parameters: |
            {
              "APPS": "[one-color]",
              "POSTMAN_BRANCH": "${{ github.ref_name }}"
            }
```
