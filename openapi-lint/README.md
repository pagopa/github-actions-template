# OpenAPI lint

This action lints an OpenAPI spec with [Spectral](https://github.com/stoplightio/spectral) and fails the check on findings at or above a configured severity.

It replaces `zuplo/rmoa-action` (Rate My OpenAPI), which depends on a cloud API key that periodically expires and blocks the pipelines, and which only exposes numeric thresholds, with no way to disable a single rule.

The action ships a default ruleset, `default.spectral.yaml`, calibrated for the eCommerce, Wallet and Checkout domains: OpenAPI plus OWASP rules, with the rate limiting and CORS rules disabled (both are handled by APIM) and the OWASP API4 resource consumption family reported as `info`. A repository that needs different rules commits its own and passes it as `ruleset`.

## Usage

```yaml
- uses: actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5 # v4

- name: OpenAPI lint - ${{ matrix.spec.version }}
  uses: pagopa/github-actions-template/openapi-lint@<commit-sha> # pin the SHA
  with:
    spec_path: ${{ matrix.spec.path }}
```

With a ruleset owned by the calling repository, and in report-only mode:

```yaml
- name: OpenAPI lint - ${{ matrix.spec.version }}
  uses: pagopa/github-actions-template/openapi-lint@<commit-sha> # pin the SHA
  with:
    spec_path: ${{ matrix.spec.path }}
    ruleset: .spectral.yaml
    fail_on_violation: false
```

The spec matrix stays in the calling workflow, because the number of specs differs per repository. Pin the action by full commit SHA, the way the consuming repositories pin every action.

## Input

| Param                 | Description                                              | Required | Values                                            | Default |
|-----------------------|----------------------------------------------------------|----------|---------------------------------------------------|---------|
| spec_path             | OpenAPI spec to lint, relative to the repository root     | **true** | `string`                                          |         |
| ruleset               | Spectral ruleset in the calling repository                | false    | `string`: empty means the bundled ruleset         |         |
| fail_severity         | Lowest severity that fails the check                      | false    | `error` \| `warn` \| `info`                        | warn    |
| fail_on_violation     | Whether a blocking finding fails the check                | false    | `boolean`                                         | true    |
| spectral_version      | Version of `@stoplight/spectral-cli`                      | false    | `string`                                          | 6.16.3  |
| owasp_ruleset_version | Version of `@stoplight/spectral-owasp-ruleset`            | false    | `string`                                          | 2.0.1   |

## Output

None. The result is the exit status of the check, the annotations on the pull request and the counts in the job summary.

## Behaviour worth knowing

**A lint that cannot run fails the check, in report-only mode too.** Spectral exits `1` when it finds results but `2` or more when it could not run at all, and in that case it writes no report. A gate that does not tell the two apart passes silently and stops protecting anything. An unloadable ruleset is a configuration error, not a finding, so `fail_on_violation: false` does not suppress it.

Two cases need more than the exit code, since Spectral reports them as ordinary findings: an unrecognised document yields exit `0` and one `unrecognized-format` **warning** having run no rules, and an unparseable spec yields `parser` findings. Both are configuration errors, so neither `fail_severity` nor `fail_on_violation` suppresses them.

**Noise is handled by severity, not by a budget.** There is deliberately no `max_warnings`. A rule too noisy to block on is downgraded by name in the ruleset, with its reason, so the exception is visible in review; a numeric budget hides findings by count and, as the Rate My OpenAPI rollout showed, only ever grows. A repository still working through its warnings migrates with `fail_severity: error` and tightens to `warn` once its spec is clean, which is a one-line change visible in the diff.

**Only errors and warnings are annotated on the pull request.** GitHub renders at most 10 annotations per type per step, so annotating info findings as well would push the actionable ones out of view. Info findings are reported as counts, broken down by rule, in the job summary.

**The npm packages are installed next to the ruleset.** Spectral resolves the packages a ruleset extends starting from the directory of the ruleset file. The install creates only a `node_modules` directory, no `package.json` and no lock file, so it cannot dirty the calling repository.
