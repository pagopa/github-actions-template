#!/usr/bin/env bash
# Lints an OpenAPI spec with Spectral and gates the job on the number of findings.
# Inputs arrive as environment variables, see action.yml.
set -euo pipefail

: "${SPEC_PATH:?SPEC_PATH is required}"
: "${MAX_ERRORS:?MAX_ERRORS is required}"
: "${MAX_WARNINGS:?MAX_WARNINGS is required}"
: "${FAIL_ON_VIOLATION:?FAIL_ON_VIOLATION is required}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# An empty ruleset means the calling repository has no ruleset of its own and takes the
# one bundled with this action.
RULESET="${RULESET:-${SCRIPT_DIR}/default.spectral.yaml}"
SPECTRAL_BIN="${SPECTRAL_BIN:-$(dirname "$RULESET")/node_modules/.bin/spectral}"

if [ ! -f "$SPEC_PATH" ]; then
  echo "::error::OpenAPI spec not found: ${SPEC_PATH}"
  exit 1
fi
if [ ! -f "$RULESET" ]; then
  echo "::error::Spectral ruleset not found: ${RULESET}"
  exit 1
fi

echo "Linting ${SPEC_PATH} with ${RULESET}"

OUT="$(mktemp)"
trap 'rm -f "$OUT"' EXIT

# Spectral exits 0 when it finds nothing above the fail severity, 1 when it has results,
# and 2 or more when it could not run at all. In that last case it writes no JSON, so a
# gate that only reads the JSON would pass silently and quietly stop checking anything.
# Both conditions are therefore verified: the exit code and a non-empty report.
set +e
"$SPECTRAL_BIN" lint --ruleset "$RULESET" --format json --output "$OUT" --quiet "$SPEC_PATH"
RC=$?
set -e

if [ "$RC" -gt 1 ] || [ ! -s "$OUT" ]; then
  echo "::error file=${SPEC_PATH}::Spectral could not lint ${SPEC_PATH} (exit ${RC}): unloadable ruleset or unparseable spec. Failing the job rather than reporting a clean run."
  exit 1
fi

count_severity() {
  jq --argjson s "$1" '[.[] | select(.severity == $s)] | length' "$OUT"
}
ERRORS=$(count_severity 0)
WARNINGS=$(count_severity 1)
INFOS=$(count_severity 2)

# Annotations for errors and warnings only. GitHub renders at most 10 annotations per
# type per step, so annotating info findings too would bury the ones worth acting on.
# The info findings are reported as counts in the job summary instead.
jq -r --arg f "$SPEC_PATH" '
  .[]
  | select(.severity <= 1)
  | "::\(if .severity == 0 then "error" else "warning" end) title=\(.code),file=\($f),line=\(.range.start.line + 1),endLine=\(.range.end.line + 1),col=\(.range.start.character + 1)::\(.message | gsub("\n"; " "))"
' "$OUT"

echo "${SPEC_PATH}: ${ERRORS} error(s) of max ${MAX_ERRORS}, ${WARNINGS} warning(s) of max ${MAX_WARNINGS}, ${INFOS} info"

if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
  {
    echo "### OpenAPI lint: \`${SPEC_PATH}\`"
    echo ""
    echo "| Severity | Findings | Threshold |"
    echo "| --- | --- | --- |"
    echo "| Error | ${ERRORS} | ${MAX_ERRORS} |"
    echo "| Warning | ${WARNINGS} | ${MAX_WARNINGS} |"
    echo "| Info | ${INFOS} | not gated |"
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

# In report-only mode the threshold messages are warnings, so that a job which is not
# meant to fail does not display red errors on the pull request.
GATE_LEVEL="error"
if [ "$FAIL_ON_VIOLATION" != "true" ]; then
  GATE_LEVEL="warning"
fi

VIOLATION=0
if [ "$ERRORS" -gt "$MAX_ERRORS" ]; then
  echo "::${GATE_LEVEL} file=${SPEC_PATH}::${ERRORS} errors exceed the maximum of ${MAX_ERRORS}"
  VIOLATION=1
fi
if [ "$WARNINGS" -gt "$MAX_WARNINGS" ]; then
  echo "::${GATE_LEVEL} file=${SPEC_PATH}::${WARNINGS} warnings exceed the maximum of ${MAX_WARNINGS}"
  VIOLATION=1
fi

if [ "$VIOLATION" -eq 0 ]; then
  exit 0
fi
if [ "$FAIL_ON_VIOLATION" = "true" ]; then
  exit 1
fi

echo "Thresholds exceeded, not failing the job because fail_on_violation is false"
exit 0
