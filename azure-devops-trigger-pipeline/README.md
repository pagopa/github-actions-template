# azure-devops-trigger-pipeline

This action helps to triggers an Azure DevOps pipeline.

## Azure PAT

the PAT which is personal to a user (we still can't have a bot) and must have the following permissions:

* build: read & execute
* code: read
* release: read

## how to use

* `azure_template_parameters` is a json string that will be passed to the Azure DevOps pipeline as parameters.

```yaml
  azure-devops-trigger:
    name: 🅰️ Azure DevOps Pipeline Trigger
    needs: payments-flow-release
    runs-on: ubuntu-22.04
    steps:
      - name: Trigger Azure DevOps Pipeline
        uses: pagopa/github-actions-template/azure-devops-trigger-pipeline@new-azdo-trigger-pipeline
        with:
          enable_azure_devops_step: 'true'
          azure_devops_project_url: 'https://dev.azure.com/pagopaspa/p4pa-projects'
          azure_devops_pipeline_name: 'p4pa-payhub-deploy-aks.deploy'
          azure_devops_pat: ${{ secrets.AZURE_DEVOPS_TOKEN }}
          azure_template_parameters: |
            {
              "APPS_TOP": "[p4pa-auth]",
              "POSTMAN_BRANCH": "${{ github.ref_name }}"
            }
```
