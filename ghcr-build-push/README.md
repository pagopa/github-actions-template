# GHCR Build Push
This action build and push the docker image on GitHub Container Registry.

The action:
- build the docker image using `Dockerfile` in the root directory
- tag and push the image on `ghcr.io`


## Usage

``` yaml
- name: Buil and Push
  uses: pagopa/github-actions-template/ghcr-build-push@main
  with:
    branch: 'main'
    tag: '1.0.0'
      
```

## Input

| Param  | Description           | Required | Values | Default |
|--------|-----------------------|----------|--------|---------|
| branch | Branch where chekcout | **true** |        |         |
| tag    | A tag for the image   | **true** |        |         |

## Output

N.A.
