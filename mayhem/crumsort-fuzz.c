#include <stdint.h>
#include <string.h>
#include "../src/crumsort.h"

/* CMPFUNC is int(*)(const void*, const void*) — return int, not uint8_t (clang 19 errors otherwise). */
int cmp_func(const void* a, const void* b) {
    return (int)*(const uint8_t *)a - (int)*(const uint8_t *)b;
}

uint8_t input_data[16000];

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    if (size > sizeof(input_data)) size = sizeof(input_data);
    memcpy(input_data, data, size);
    crumsort(input_data, size, sizeof(char), cmp_func);
    return 0;
}
