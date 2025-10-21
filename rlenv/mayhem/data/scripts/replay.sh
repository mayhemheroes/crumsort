#! /bin/bash

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 [FILE]"
    exit 1
fi

# Disable ASLR for deterministic crash behavior
# This ensures that crashes are reproducible regardless of memory layout randomization
# Use noaslr if available, otherwise fall back to setarch
if command -v noaslr >/dev/null 2>&1; then
    noaslr /crumsort-fuzz $1
else
    setarch $(uname -m) -R /crumsort-fuzz $1
fi