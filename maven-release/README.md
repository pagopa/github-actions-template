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
  uses: pagopa/github-actions-template/maven-release@v1
  with:
    semver: 'major'
    github_token: ${{ secrets.GITHUB_TOKEN }}
    skip_ci: true
    beta: false
    jdk_version: 11
    prerelease: false
    only_tag: false
      
- run: echo "${{ steps.release.outputs.version }}"
```

## Input

| Param        | Description                                               | Required | Values                                           | Default |
|--------------|-----------------------------------------------------------|----------|--------------------------------------------------|---------|
| semver       | Select the new Semantic Version                           | **true** | `major`, `minor`, `patch`, `buildNumber`, `skip` |         |
| github_token | A GitHub token                                            | **true** | `string`                                         |         |
| beta         | True if it is a beta version (update canary helm version) | false    | `boolean`                                        | false   |
| skip_ci      | True if you want skip CI workflows on commit release      | false    | `boolean`                                        | true    |  
| jdk_version  | Select the JDK version                                    | false    | `11`, `17`                                       | `11`    |
| prerelease   | True if it is a prerelease                                | false    | `boolean`                                        | false   |
| only_tag     | True to create only the Tag without the Release           | false    | `boolean`                                        | false   |

## Output

| Value   | Description |
|---------|-------------|
| version | New Version |
