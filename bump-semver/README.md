# Bump Semver

This action calculate the new semantic version according the inputs.

The new version is saved in the output.

## Usage

``` yaml
- name: Bump Version
  id: bump_version
  uses: pagopa/github-actions-template/bump-semver@v1
  with:
    semver: 'major'
    current_version: 'v1.0.0-2'
      
- run: echo "${{ steps.bump_version.outputs.new_version }}"
```

## Input

| Param           | Description                     | Required | Values                                           | Default |
|-----------------|---------------------------------|----------|--------------------------------------------------|---------|
| current_version | The current version             | **true** | `string` (ex: `v1.0.0`)                          |         |
| semver          | Select the new Semantic Version | **true** | `major`, `minor`, `patch`, `buildNumber`, `skip` |         |

## Output

| Value       | Description |
|-------------|-------------|
| new_version | New Version |
