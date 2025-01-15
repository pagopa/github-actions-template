# payments-flow-release

Allows to make a release and build a docker image with the follow tags:

- develop-vX.Y.Z + develop-latest + latest
- uat-vX.Y.Z + uat-latest
- vX.Y.Z

## how to use

```yaml
name: 🚀 Flow Release

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

  checkout:
    name: 🔖 Checkout Repository
    runs-on: ubuntu-22.04
    steps:
      - name: Checkout code
        uses: actions/checkout@eef61447b9ff4aafe5dcd4e0bbf5d482be7e7871
        with:
          ref: ${{ github.ref_name }}

  payments-flow-release:
    name: 🚀 Release
    runs-on: ubuntu-22.04
    needs: checkout
    steps:
      - name: 🚀 release + docker
        # https://github.com/pagopa/github-actions-template/releases/tag/v1.19.1
        uses: pagopa/github-actions-template/payments-flow-release@new-azdo-trigger-pipeline
        with:
          current_branch: ${{ github.ref_name }}
```
