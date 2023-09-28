# Azure Functions Deploy

This action makes a deployment of an Azure functions using a docker image.

```
on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
      target:
        required: true
        type: string
      app_name:
        required: true
        type: string
      registry_image:
        required: true
        type: string
        
  [...]
        
  deploy:
    name: Deploy Azure Function
    runs-on: ubuntu-22.04
    uses: pagopa/github-actions-template/azure-function-deploy@v1
    with:
      branch: ${{ github.ref_name }}
      client_id: ${{ secrets.CLIENT_ID }}
      tenant_id: ${{ secrets.TENANT_ID }}
      subscription_id: ${{ secrets.SUBSCRIPTION_ID }}
      app_name: ${{ inputs.app_name }}
      registry_image: ${{ inputs.registry_image }}
```
