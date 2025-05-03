#!/usr/bin/env bash

# Set up error handling
set -e

# Script variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYBOOK_PATH="${SCRIPT_DIR}/final-deployment-validation.yml"
RESULTS_DIR="${SCRIPT_DIR}/../../deploy-test-results"

# Function to run deployment tests
run_deployment_tests() {
    local image_tag="${1:-test}"

    # Setup result directory
    mkdir -p "${RESULTS_DIR}"

    # Execute tests
    echo "=== Running Ansible Runtime Tests ==="
    docker run --rm \
        -v "${PLAYBOOK_PATH}:/playbook.yml" \
        "ansible-test:${image_tag}" \
        ansible-playbook -c local -i localhost, -e "test_var=deployment_test" /playbook.yml # DevSkim: ignore DS162092

    # Copy test results from container
    echo "=== Collecting Test Results ==="
    docker run --rm \
        -v "${RESULTS_DIR}:/output" \
        "ansible-test:${image_tag}" \
        sh -c "if [ -f /tmp/deployment-test-results.txt ]; then cp /tmp/deployment-test-results.txt /output/; else echo 'No test results found' > /output/error.txt; fi"

    echo "=== Test completed ==="
}

# Main execution
main() {
    # Check if a specific tag was provided
    if [ $# -eq 1 ]; then
        run_deployment_tests "$1"
    else
        run_deployment_tests
    fi
}

# Execute the script
main "$@"
