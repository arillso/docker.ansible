#!/bin/bash

# Performance Test Script for Ansible Docker Container
set -e

RESULTS_DIR="/results"
mkdir -p $RESULTS_DIR

# Time measurement for various operations
{
    echo "==== Ansible Container Performance Tests ==="
    date

    # Test 1: Ansible Module Loading Time
    echo -e "\n\n-- Test 1: Ansible Module Loading Time --"
    { time ansible --version >/dev/null; } 2>&1

    # Test 2: Playbook Execution Speed
    echo -e "\n\n-- Test 2: Playbook Execution Speed --"
    # Execute benchmark playbook
    { time ansible-playbook /tests/bench.yml -c local >/dev/null; } 2>&1

    # Test 3: Mitogen Accelerator Test (if installed)
    echo -e "\n\n-- Test 3: Mitogen Accelerator Test --"
    # Execute mitogen benchmark playbook
    { time ansible-playbook /tests/bench-mitogen.yml -c local >/dev/null 2>&1 || echo "Mitogen not available"; } 2>&1

    # Test 4: Python Import Speed for Main Modules
    echo -e "\n\n-- Test 4: Python Module Import Speed --"
    # Execute python import test
    python /tests/import_test.py

    # Test 5: Memory Usage
    echo -e "\n\n-- Test 5: Memory Usage --"
    # Try to install psutil package if not available, but don't fail if it can't be installed
    python -m pip install --quiet psutil || echo "Could not install psutil, using alternative memory check"
    python /tests/memory_test.py

    echo -e "\n\nPerformance tests completed."
} >>"$RESULTS_DIR/perf-results.txt"

cat $RESULTS_DIR/perf-results.txt
