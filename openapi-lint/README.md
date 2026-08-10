# OpenAPI lint

This action lints an OpenAPI spec with [Spectral](https://github.com/stoplightio/spectral) and fails the check when the findings exceed the configured thresholds.

It replaces `zuplo/rmoa-action` (Rate My OpenAPI), which depends on a cloud API key that periodically expires and blocks the pipelines, and which only exposes numeric thresholds, with no way to disable a single rule.

The action ships a default ruleset, `default.spectral.yaml`, calibrated for the eCommerce, Wallet and Checkout domains: OpenAPI plus OWASP rules, with the rate limiting and CORS rules disabled (both are handled by APIM) and the OWASP API4 resource consumption family reported as `info`. A repository that needs different rules commits its own and passes it as `ruleset`.

## Usage

```yaml
- uses: actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5 # v4

- name: OpenAPI lint - ${{ matrix.spec.version }}
  uses: pagopa/github-actions-template/openapi-lint@v1
  with:
    spec_path: ${{ matrix.spec.path }}
```

With a ruleset owned by the calling repository, and in report-only mode:

```yaml
- name: OpenAPI lint - ${{ matrix.spec.version }}
  uses: pagopa/github-actions-template/openapi-lint@v1
  with:
    spec_path: ${{ matrix.spec.path }}
    ruleset: .spectral.yaml
    fail_on_violation: false
```

The spec matrix stays in the calling workflow, because the number of specs differs per repository. Repositories that pin actions by commit SHA should do the same here.

## Input

| Param                 | Description                                              | Required | Values                                            | Default |
|-----------------------|----------------------------------------------------------|----------|---------------------------------------------------|---------|
| spec_path             | OpenAPI spec to lint, relative to the repository root     | **true** | `string`                                          |         |
| ruleset               | Spectral ruleset in the calling repository                | false    | `string`: empty means the bundled ruleset         |         |
| max_errors            | Error findings tolerated before the check fails           | false    | `number`                                          | 0       |
| max_warnings          | Warning findings tolerated before the check fails         | false    | `number`                                          | 0       |
| fail_on_violation     | Whether exceeding a threshold fails the check             | false    | `boolean`                                         | true    |
| spectral_version      | Version of `@stoplight/spectral-cli`                      | false    | `string`                                          | 6.16.3  |
| owasp_ruleset_version | Version of `@stoplight/spectral-owasp-ruleset`            | false    | `string`                                          | 2.0.1   |

## Output

None. The result is the exit status of the check, the annotations on the pull request and the counts in the job summary.

## Behaviour worth knowing

**A lint that cannot run fails the check, in report-only mode too.** Spectral exits `1` when it finds results but `2` or more when it could not run at all, and in that case it writes no report. A gate that does not tell the two apart passes silently and stops protecting anything. An unloadable ruleset is a configuration error, not a finding, so `fail_on_violation: false` does not suppress it.

**Only errors and warnings are annotated on the pull request.** GitHub renders at most 10 annotations per type per step, so annotating info findings as well would push the actionable ones out of view. Info findings are reported as counts, broken down by rule, in the job summary.

**The npm packages are installed next to the ruleset.** Spectral resolves the packages a ruleset extends starting from the directory of the ruleset file. The install creates only a `node_modules` directory, no `package.json` and no lock file, so it cannot dirty the calling repository.
