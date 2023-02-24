# Maven Semantic Version

This action updates the version of the project using the semantic version passed in input.

Note: The project must have [this structure](https://github.com/pagopa/template-java-spring-microservice).

The action updates:

- the pom version (`/pom.xml`)
- the helm chart versions (`/helm/values-*.yaml`)
- the openapi/swagger version (`/openapi/openapi.json` json or yaml)

The new version is saved in the output.

## Usage

``` yaml
- name: Update Semantic Version
  id: semver
  uses: pagopa/github-actions-template/maven-semver@v1
  with:
    semver: 'major'
      
- run: echo "${{ steps.semver.outputs.version }}"
```

## Input

| Param  | Description                     | Required | Values                                           | Default |
|--------|---------------------------------|----------|--------------------------------------------------|---------|
| semver | Select the new Semantic Version | **true** | `major`, `minor`, `patch`, `buildNumber`, `skip` |         |

## Output

| Value   | Description |
|---------|-------------|
| version | New Version |
