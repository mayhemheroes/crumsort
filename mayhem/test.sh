#!/usr/bin/env bash
#
# crumsort/mayhem/test.sh — correctness oracle for crumsort → CTRF.
# crumsort upstream ships only a benchmark (src/bench.c) that prints "not properly sorted" but
# ALWAYS exits 0, so it cannot gate a patch. mayhem/sort_test.c is our authored correctness check:
# it sorts varied arrays with crumsort() and compares against qsort(); any mismatch fails (exit 1).
# Built with the project's NORMAL flags (no fuzz sanitizers) — an independent functional oracle.
set -uo pipefail
[ -n "${SOURCE_DATE_EPOCH:-}" ] || unset SOURCE_DATE_EPOCH
: "${CC:=clang}"
cd "$SRC"

# emit_ctrf <tool> <passed> <failed> [skipped] [pending] [other]
emit_ctrf() {
  local tool="$1" passed="$2" failed="$3" skipped="${4:-0}" pending="${5:-0}" other="${6:-0}"
  local tests=$(( passed + failed + skipped + pending + other ))
  cat > "${CTRF_REPORT:-$SRC/ctrf-report.json}" <<JSON
{
  "results": {
    "tool": { "name": "$tool" },
    "summary": {
      "tests": $tests,
      "passed": $passed,
      "failed": $failed,
      "pending": $pending,
      "skipped": $skipped,
      "other": $other
    }
  }
}
JSON
  printf 'CTRF {"results":{"tool":{"name":"%s"},"summary":{"tests":%d,"passed":%d,"failed":%d,"pending":%d,"skipped":%d,"other":%d}}}\n' \
    "$tool" "$tests" "$passed" "$failed" "$pending" "$skipped" "$other"
  [ "$failed" -eq 0 ]
}

BIN=/mayhem/crumsort_selftest
[ -x "$BIN" ] || { echo "missing $BIN — run mayhem/build.sh first" >&2; exit 2; }
out="$("$BIN" 2>&1)"; echo "$out"

passed=$(printf '%s\n' "$out" | sed -n 's/.*SORTTEST passed=\([0-9][0-9]*\) .*/\1/p' | tail -1)
failed=$(printf '%s\n' "$out" | sed -n 's/.*SORTTEST .*failed=\([0-9][0-9]*\) .*/\1/p' | tail -1)
: "${passed:=0}" "${failed:=1}"

emit_ctrf "crumsort-selftest" "$passed" "$failed"
