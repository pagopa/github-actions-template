# Package

This action create the artifact package of the maven project and uploads it on GitHub.

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
    github_token: ${{ secrets.GITHUB_TOKEN }}
    branch: ${{ github.ref_name }}
```

## Input

| Param         | Description            | Required | Values   | Default |
|---------------|------------------------|----------|----------|---------|
| github_token  | A GitHub token         | **true** | `string` |         |
| branch        | Git branch             | **true** | `string` |         |
| jdk_version   | Select the JDK version | false    | `string` | `11`    |
| maven_version | Maven version to use   | false    | `string` | `3.8.2` |

## Output

No output defined.
