# Semver setup

This action generates the `semver` as output according to the issue label.

If a pull request is merged with **one** of the following labels you can use this action to read the label and set as
output the value to use in other steps of your pipeline:

- `major`
- `minor`
- `patch`
- `skip`

**Note**: you can also use this action with `workflow_discpatch`. In this way is available also the value `buildNumber`.

## Usage

``` yaml
on:
  pull_request:
    
  workflow_dispatch:
    inputs:      
      semver:
        required: true
        type: choice
        description: Select the new Semantic Version
        options:
          - major
          - minor
          - patch
          - buildNumber
          - skip
  
  [...]
  steps:  
    - name: Get semver
      id: get_semver
      uses: pagopa/github-actions-template/semver-setup@v1

    - run: echo "${{ steps.get_semver.outputs.semver }}"
```

## Input

No input required.

## Output

| Value  | Description    |
|--------|----------------|
| semver | Semver Version |
