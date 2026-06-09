/* mayhem/sort_test.c — correctness oracle for crumsort (the upstream repo ships only a benchmark
 * that never fails on a bad sort). Sorts a variety of int arrays with crumsort() and compares the
 * result against a qsort() reference; any mismatch or out-of-order element is a FAIL. Deterministic
 * (fixed PRNG) so results are reproducible. Prints per-case lines + a summary; exit 0 iff all pass. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "../src/crumsort.h"

static int cmp_int(const void *a, const void *b) {
    int x = *(const int *)a, y = *(const int *)b;
    return (x > y) - (x < y);
}

/* xorshift32 — deterministic, no libc rng dependence */
static uint32_t rs = 0x9e3779b9u;
static uint32_t xrand(void) { rs ^= rs << 13; rs ^= rs >> 17; rs ^= rs << 5; return rs; }

static int passed = 0, failed = 0;

static void check(const char *name, const int *src, size_t n) {
    int *a   = malloc(n * sizeof(int) + 1);
    int *ref = malloc(n * sizeof(int) + 1);
    memcpy(a, src, n * sizeof(int));
    memcpy(ref, src, n * sizeof(int));
    crumsort(a, n, sizeof(int), cmp_int);
    qsort(ref, n, sizeof(int), cmp_int);
    int ok = 1;
    for (size_t i = 0; i < n; i++)        if (a[i] != ref[i])  { ok = 0; break; }  /* same multiset, sorted */
    for (size_t i = 1; i < n && ok; i++)  if (a[i - 1] > a[i]) { ok = 0; }         /* explicitly ordered */
    printf("  %-20s n=%-6zu %s\n", name, n, ok ? "PASS" : "FAIL");
    ok ? passed++ : failed++;
    free(a); free(ref);
}

int main(void) {
    static int buf[20000];
    size_t i;

    check("empty", buf, 0);
    buf[0] = 42; check("single", buf, 1);

    for (i = 0; i < 1000; i++) buf[i] = (int)i;            check("already-sorted", buf, 1000);
    for (i = 0; i < 1000; i++) buf[i] = (int)(999 - i);    check("reverse-sorted", buf, 1000);
    for (i = 0; i < 500;  i++) buf[i] = 7;                 check("all-equal", buf, 500);
    for (i = 0; i < 100;  i++) buf[i] = (int)(xrand() % 1000);            check("random-small", buf, 100);
    for (i = 0; i < 5000; i++) buf[i] = (int)(xrand() % 10);             check("many-duplicates", buf, 5000);
    for (i = 0; i < 20000;i++) buf[i] = (int)(xrand());                  check("random-large", buf, 20000);
    for (i = 0; i < 1000; i++) buf[i] = (int)((i % 2) ? -(int)i : (int)i); check("alternating-signed", buf, 1000);

    int total = passed + failed;
    printf("SORTTEST passed=%d failed=%d total=%d\n", passed, failed, total);
    return failed ? 1 : 0;
}
