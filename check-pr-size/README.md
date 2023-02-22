# Check PR Size

This action check the size of a PR.

- If the size is smaller than `min_size` (default: 200 changes) the label `size/small` is added to the pull request.
- If the size is greater than `max_size` (default: 400 changes) the label `size/large` is added to the pull request and
  the **check fails**.

## Usage

``` yaml
- name: Check PR Size
  uses: pagopa/github-actions-template/check-pr-size@v1
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    ignored_files: 'openapi.json, .github/'
    min_size: 200
    max_size: 400
      
```

## Input

| Param         | Description                  | Required | Values                                                 | Default |
|---------------|------------------------------|----------|--------------------------------------------------------|---------|
| github_token  | A GitHub token               | **true** | `string`                                               |         |
| ignored_files | File to ignore               | false    | `string`: directory, or file to ignore (**csv style**) |         |
| min_size      | Minimum size of pull request | false    | `number`                                               | 200     |
| max_size      | Maximum size of pull request | false    | `number`                                               | 400     |

## Output

| Value   | Description |
|---------|-------------|
| version | New Version |
