# Package
This action create the artifact package of the maven project and uploads it on GitHub.

Note: The project must have [this structure](https://github.com/pagopa/template-java-spring-microservice).

The action:
- checkout on git branch
- build maven package
- pushes to GitHub package registry

## Usage

``` yaml
- name: Make Package
  id: package
  uses: pagopa/github-actions-template/maven-package@v1
  with:
    github_token: ${{ secrets.BOT_GITHUB_TOKEN }}
    branch: ${{ github.ref_name }}
```

## Input

| Param        | Description    | Required | Values                                           | Default |
|--------------|----------------|----------|--------------------------------------------------|---------|
| github_token | A GitHub token | **true** | `string`                                         |         |
| branch       | Git branch     | **true** | `string`                                         |         |

## Output
No output defined.
