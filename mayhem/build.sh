#!/usr/bin/env bash
# crumsort/mayhem/build.sh — build the crumsort libFuzzer harness with ASan+UBSan.
set -euo pipefail
[ -n "${SOURCE_DATE_EPOCH:-}" ] || unset SOURCE_DATE_EPOCH
: "${SANITIZER_FLAGS=-fsanitize=address,undefined -fno-sanitize-recover=all -fno-omit-frame-pointer -g}"
: "${DEBUG_FLAGS:=-g -gdwarf-3}"
: "${CC:=clang}" ; : "${LIB_FUZZING_ENGINE:=-fsanitize=fuzzer}" ; : "${MAYHEM_JOBS:=$(nproc)}"
export SANITIZER_FLAGS DEBUG_FLAGS CC LIB_FUZZING_ENGINE MAYHEM_JOBS
cd "$SRC"
# crumsort is header-only (src/crumsort.h); the harness includes it directly.
$CC $SANITIZER_FLAGS $DEBUG_FLAGS $LIB_FUZZING_ENGINE mayhem/crumsort-fuzz.c -o /mayhem/crumsort-fuzz
# also a standalone (non-fuzzer) reproducer: same harness + LLVM's standalone main, no fuzzing engine.
$CC $SANITIZER_FLAGS $DEBUG_FLAGS "$STANDALONE_FUZZ_MAIN" mayhem/crumsort-fuzz.c -o /mayhem/crumsort-fuzz-standalone

# Build the correctness oracle too (NORMAL flags) so mayhem/test.sh only runs it. crumsort ships
# only a benchmark that never fails; mayhem/sort_test.c sorts varied arrays and checks vs qsort().
"$CC" -O2 -o /mayhem/crumsort_selftest "$SRC/mayhem/sort_test.c"
