# Check PR Size

This action adds a label to PR.

## Usage

``` yaml
- name: Add PR label
  uses: pagopa/github-actions-template/default-label@v1
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    label: 'patch'
      
```

## Input

| Param        | Description                  | Required | Values   | Default |
|--------------|------------------------------|----------|----------|---------|
| github_token | A GitHub token               | **true** | `string` |         |
| label        | Label to add                 | false    | `string` |         |

## Output

| Value   | Description |
|---------|-------------|
| version | New Version |
