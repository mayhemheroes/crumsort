#! /bin/bash

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 [FILE]"
    exit 1
fi

# Disable ASLR for deterministic crash behavior
# This ensures that crashes are reproducible regardless of memory layout randomization
setarch $(uname -m) -R /crumsort-fuzz $1