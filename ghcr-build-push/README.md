# GHCR Build Push

This action build and push the docker image on GitHub Container Registry.

The action:

- build the docker image using `Dockerfile` in the root directory
- tag and push the image on `ghcr.io`

👀 **Important!**

Remember to add the package write permissions to the
action https://github.com/users/OWNER/packages/container/REPOSITORY/settings

## Usage

``` yaml
- name: Buil and Push
  uses: pagopa/github-actions-template/ghcr-build-push@v1
  with:
    branch: 'main'
    tag: '1.0.0'
    github_token: ${{ secrets.GITHUB_TOKEN }}
      
```

## Input

| Param        | Description           | Required | Values   | Default |
|--------------|-----------------------|----------|----------|---------|
| branch       | Branch where chekcout | **true** | `string` |         |
| tag          | A tag for the image   | **true** | `string` |         |
| github_token | A GitHub token        | **true** | `string` |         |

## Output

N.A.
