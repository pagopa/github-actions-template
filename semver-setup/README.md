# Semver setup
This action generates the semver according to the issue label 

Note: The project must have [this structure](https://github.com/pagopa/template-java-spring-microservice).

## Usage

``` yaml
- name: Set semver
  id: semver
  uses: pagopa/github-actions-template/semver-setup@v1
```

## Input
No input required.

## Output
| Value  | Description    |
|--------|----------------|
| semver | Semver Version |
