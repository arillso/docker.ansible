#!/usr/bin/env bash
#
# Description: Generate a markdown summary of Ansible container test results
# Usage:       ./container-test-summary.sh <Test1=status> [Test2=status ...]
# Exit Code:   Always exits with 0 so that downstream steps can run regardless of failures.
#

set -euo pipefail

# Determine script directory for proper relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_DIR="${SCRIPT_DIR}/../.github/scripts/utils"

# Execute the shared summary generator with test-specific parameters
"${UTILS_DIR}/generate-summary.sh" \
    --title "Ansible Container Tests Summary" \
    --output "./container-test-results.md" \
    "$@"

# Add extra environment information specific to container tests
if grep -q "ANSIBLE_VERSION" <(env); then
    sed -i '/^- \*\*GitHub Run ID:\*\*/a - **Ansible Version:** '"${ANSIBLE_VERSION:-Unknown}" "./container-test-results.md"
fi

echo "Test summary generated at ./container-test-results.md"
exit 0
