# Helm Bump

This action updates the version of the Helm Chart and the images in the helm values.

Note: The project must have [this structure](https://github.com/pagopa/template-java-spring-microservice).

The action updates:

- the helm chart versions (`/helm/Chart.yaml`)
- the helm values files (`/helm/values-*.yaml`)

## Usage

``` yaml
- name: Update Semantic Version
  id: semver
  uses: pagopa/github-actions-template/helm-bump@v1
  with:
    version: '2.3.5'
    beta: false
      
```

## Input

| Param   | Description                                               | Required | Values    | Default |
|---------|-----------------------------------------------------------|----------|-----------|---------|
| version | The new version                                           | **true** | string    |         |
| beta    | True if it is a beta version (update canary helm version) | **true** | `boolean` | false   |

## Output

N.A.
