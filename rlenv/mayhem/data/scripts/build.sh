#!/bin/bash
set -euo pipefail

# RLENV Build Script
# This script rebuilds the application from source located at /rlenv/source/crumsort/
#
# Original image: ghcr.io/mayhemheroes/crumsort:main
# Git revision: 388d2aa0adf42afd65e6199a08354ccbcc28c2c5

# Change to the source directory
cd /rlenv/source/crumsort

# Build the fuzz target
cd fuzz
make

# Copy build artifacts to expected location (preserving permissions from Docker build)
cp /rlenv/source/crumsort/fuzz/crumsort-fuzz /crumsort-fuzz

# Verify build artifacts exist
if [ ! -f /crumsort-fuzz ]; then
    echo "Error: Build artifact crumsort-fuzz not found at /crumsort-fuzz"
    exit 1
fi

echo "Build completed successfully. Fuzzer binary available at /crumsort-fuzz"
