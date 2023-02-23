# AKS Deploy

This action makes a deployment on AKS of a docker image.

## Usage

``` yaml
- name: Deploy
  uses: pagopa/github-actions-template/aks-deploy@v1
  with:
    branch: 'main'
    client_id: 'xxx-xxx'
    subscription_id: 'xxx-xxx'
    tenant_id: 'xxx-xxx'
    env: 'dev'
    namespace: 'your-name-space'
    cluster_name: 'your-cluster-name'
    resource_group: 'your-resource-group'
    app_name: 'myapp'
```

## Input

| Param           | Description                       | Required | Values               | Default |
|-----------------|-----------------------------------|----------|----------------------|---------|
| branch          | Git branch                        | **true** | `string`             |         |
| client_id       | Azure Client ID                   | **true** | `string`             |         |
| subscription_id | Azure Subscription ID             | **true** | `string`             |         |
| tenant_id       | Azure Tenant ID                   | **true** | `string`             |         |
| env             | The environment where to deploy   | **true** | `dev`, `uat`, `prod` |         |
| namespace       | The namespace on AKS              | **true** | `string`             |         |
| cluster_name    | The name of the cluster           | **true** | `string`             |         |
| resource_group  | The resource group of the cluster | **true** | `string`             |         |
| app_name        | The name of the application       | **true** | `string`             |         |

## Output

| Value   | Description |
|---------|-------------|
| version | New Version |
