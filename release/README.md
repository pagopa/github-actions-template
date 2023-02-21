# Release
This action updates the version of the project using the semantic version and makes a release on GitHub.

Note: The project must have [this structure](https://github.com/pagopa/template-java-spring-microservice).

The action:
- calls the `maven-semver` template to update the version of the project
- pushes to GitHub
- make a new Tag and Release on GitHub

The new version is saved in the output.

## Usage

``` yaml
- name: Make Release
  id: release
  uses: pagopa/github-actions-template/release@v1
  with:
    semver: 'major'
      
- run: echo "${{ steps.release.outputs.version }}"
```

## Input

| Param        | Description                     | Required | Values                                           | Default |
|--------------|---------------------------------|----------|--------------------------------------------------|---------|
| semver       | Select the new Semantic Version | **true** | `major`, `minor`, `patch`, `buildNumber`, `skip` |         |
| github_token | A GitHub token                  | **true** | `string`                                         |         |

## Output
| Value   | Description |
|---------|-------------|
| version | New Version |
