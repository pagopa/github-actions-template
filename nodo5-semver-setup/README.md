# Semver setup

This action generates the `semver` and the `environment` as output according to the issue label and 
the passed action.  
The semantic version that can be inserted are the following:  
```
 - '' -> only in DEV environment on branch != main execute a buildNumber update on the version
 - promote -> do not execute any update on the version
 - patch -> execute a patch update on the version, i.e. the third cypher on x.y.Z
 - new_release -> execute a minor update on the version, i.e. the second cypher on x.Y.z
 - breaking_change -> execute a major update on the version, i.e. the first cypher on X.y.z
```
The following strategy is accepted for the generation of the semantic version with this action:
```
IF environment=dev THEN
    accept [''], [skip], [patch], [new-release] and [breaking-change]
IF environment=uat THEN
    accept only [promote] or [patch]
IF environment=prod THEN
    accept only [promote] or [patch]
```


## Usage

``` yaml
on:
  pull_request:
    
  workflow_dispatch:
    inputs:  
      environment:
        required: true
        type: choice
        description: Select the Environment
        options:
          - dev
          - uat
          - prod    
      semver:
        required: false
        type: choice
        description: Select the version
        options:
          - ''
          - skip
          - promote
          - patch
          - new_release
          - breaking_change
  
  [...]
  
  steps:  
    - name: Semver setup
      id: semver_setup
      uses: pagopa/github-actions-template/node-semver-setup@v1

    - run: |
        echo "${{ steps.get_semver.outputs.semver }}"
        echo "${{ steps.get_semver.outputs.environment }}"
```

## Input

No input required.

## Output

| Value       | Description    |
|-------------|----------------|
| semver      | Semver Version |
| environment | Environment    |

