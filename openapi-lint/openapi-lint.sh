#!/usr/bin/env bash
# Lints an OpenAPI spec with Spectral and gates the job on the severity of the findings.
# Inputs arrive as environment variables, see action.yml.
set -euo pipefail

: "${SPEC_PATH:?SPEC_PATH is required}"
: "${FAIL_SEVERITY:?FAIL_SEVERITY is required}"
: "${FAIL_ON_VIOLATION:?FAIL_ON_VIOLATION is required}"
: "${SPECTRAL_VERSION:?SPECTRAL_VERSION is required}"
: "${OWASP_RULESET_VERSION:?OWASP_RULESET_VERSION is required}"

# Spectral's own severity numbering, as it appears in the JSON report.
case "$FAIL_SEVERITY" in
  error) FAIL_LEVEL=0 ;;
  warn)  FAIL_LEVEL=1 ;;
  info)  FAIL_LEVEL=2 ;;
  *)
    echo "::error::fail_severity must be error, warn or info, got '${FAIL_SEVERITY}'"
    exit 1
    ;;
esac

# An empty ruleset means the calling repository has none of its own and takes the one
# bundled with this action, which sits next to this script.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULESET="${RULESET:-${SCRIPT_DIR}/default.spectral.yaml}"

if [ ! -f "$SPEC_PATH" ]; then
  echo "::error::OpenAPI spec not found: ${SPEC_PATH}"
  exit 1
fi
if [ ! -f "$RULESET" ]; then
  echo "::error::Spectral ruleset not found: ${RULESET}"
  exit 1
fi

# Spectral resolves a ruleset's npm packages from the ruleset's own directory and these
# repos have no package.json, so install there and read the binary back from the same path.
# Never skipped on an existing node_modules: that would lint with an unpinned version.
PREFIX="$(dirname "$RULESET")"
SPECTRAL_BIN="${PREFIX}/node_modules/.bin/spectral"
npm install --no-save --no-package-lock --prefix "$PREFIX" \
  "@stoplight/spectral-cli@${SPECTRAL_VERSION}" \
  "@stoplight/spectral-owasp-ruleset@${OWASP_RULESET_VERSION}"
if [ ! -x "$SPECTRAL_BIN" ]; then
  echo "::error::Spectral not found at ${SPECTRAL_BIN} after installing it there."
  exit 1
fi

OUT="$(mktemp)"
trap 'rm -f "$OUT"' EXIT

# Exit 2 or more means Spectral could not run and wrote no JSON. Check both the exit code
# and a non-empty report, or the gate passes silently and stops checking.
set +e
"$SPECTRAL_BIN" lint --ruleset "$RULESET" --format json --output "$OUT" --quiet "$SPEC_PATH"
RC=$?
set -e

if [ "$RC" -gt 1 ] || [ ! -s "$OUT" ]; then
  echo "::error file=${SPEC_PATH}::Spectral could not lint ${SPEC_PATH} (exit ${RC}): unloadable ruleset or unparseable spec. Failing the job rather than reporting a clean run."
  exit 1
fi

# Both mean nothing was linted, yet Spectral reports them as ordinary findings:
# unrecognized-format runs zero rules and is only a warning, so fail_severity: error
# would let it through. Configuration errors, so report-only does not suppress them.
UNLINTABLE=$(jq -r '[.[] | select(.code == "unrecognized-format" or .code == "parser")] | .[0].message // empty' "$OUT")
if [ -n "$UNLINTABLE" ]; then
  echo "::error file=${SPEC_PATH}::Spectral could not lint ${SPEC_PATH}: ${UNLINTABLE}. Failing the job rather than reporting a clean run."
  exit 1
fi

count_severity() {
  jq --argjson s "$1" '[.[] | select(.severity == $s)] | length' "$OUT"
}
# Report-only blocks nothing at any severity, so the summary must not claim otherwise.
blocking() {
  if [ "$FAIL_ON_VIOLATION" = "true" ] && [ "$1" -le "$FAIL_LEVEL" ]; then echo "yes"; else echo "no"; fi
}
ERRORS=$(count_severity 0)
WARNINGS=$(count_severity 1)
INFOS=$(count_severity 2)

# Computed here, not delegated to Spectral's --fail-severity: report-only would then have
# to swallow Spectral's exit code, reopening the exit 2 hole above.
BLOCKING=$(jq --argjson l "$FAIL_LEVEL" '[.[] | select(.severity <= $l)] | length' "$OUT")

# Errors and warnings only: GitHub renders at most 10 annotations per type per step, so
# info findings would bury them. Info goes to the job summary as counts.
jq -r --arg f "$SPEC_PATH" '
  .[]
  | select(.severity <= 1)
  | "::\(if .severity == 0 then "error" else "warning" end) title=\(.code),file=\($f),line=\(.range.start.line + 1),endLine=\(.range.end.line + 1),col=\(.range.start.character + 1)::\(.message | gsub("\n"; " "))"
' "$OUT"

echo "${SPEC_PATH}: ${ERRORS} error(s), ${WARNINGS} warning(s), ${INFOS} info; ${BLOCKING} at or above ${FAIL_SEVERITY}"

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  {
    echo "### OpenAPI lint: \`${SPEC_PATH}\`"
    echo ""
    echo "| Severity | Findings | Blocking |"
    echo "| --- | --- | --- |"
    echo "| Error | ${ERRORS} | $(blocking 0) |"
    echo "| Warning | ${WARNINGS} | $(blocking 1) |"
    echo "| Info | ${INFOS} | $(blocking 2) |"
    if [ "$FAIL_ON_VIOLATION" != "true" ]; then
      echo ""
      echo "Report-only: \`fail_on_violation\` is false, so nothing blocks this job."
    fi
    if [ "$INFOS" -gt 0 ]; then
      echo ""
      echo "<details><summary>Info findings by rule</summary>"
      echo ""
      echo "| Rule | Findings |"
      echo "| --- | --- |"
      jq -r '
        [.[] | select(.severity == 2)]
        | group_by(.code)
        | map({code: .[0].code, n: length})
        | sort_by(-.n)[]
        | "| \(.code) | \(.n) |"
      ' "$OUT"
      echo ""
      echo "</details>"
    fi
    echo ""
  } >> "$GITHUB_STEP_SUMMARY"
fi

# Report-only downgrades the gate message only. Finding annotations keep their severity.
GATE_LEVEL="error"
if [ "$FAIL_ON_VIOLATION" != "true" ]; then
  GATE_LEVEL="warning"
fi

if [ "$BLOCKING" -eq 0 ]; then
  exit 0
fi

echo "::${GATE_LEVEL} file=${SPEC_PATH}::${BLOCKING} finding(s) at or above severity ${FAIL_SEVERITY}"

if [ "$FAIL_ON_VIOLATION" = "true" ]; then
  exit 1
fi

echo "Findings at or above ${FAIL_SEVERITY}, not failing the job because fail_on_violation is false"
exit 0
