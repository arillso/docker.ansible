#!/usr/bin/env bash
#
# Description: Generate a markdown summary of Ansible container test results
# Usage:       ./container-test-summary.sh <Test1=status> [Test2=status ...]
# Exit Code:   Always exits with 0 so that downstream steps can run regardless of failures.
#

set -euo pipefail
IFS=$'\n\t'

declare -g all_passed_flag=true
declare -g output="./container-test-results.md"

write_header() {
    printf -- '## Ansible Container Tests Summary\n\n' >"$output"
}

process_tests() {
    local all_passed=true

    printf -- '| Test | Status |\n| ---- | ------ |\n' >>"$output"

    for arg in "$@"; do
        if [[ "$arg" =~ ^([^=]+)=(.+)$ ]]; then
            local name="${BASH_REMATCH[1]}"
            local status="${BASH_REMATCH[2]}"
        else
            printf -- 'Warning: invalid argument "%s"\n' "$arg" >&2
            continue
        fi

        if [[ "$status" == "success" ]]; then
            symbol='✅'
        else
            symbol='❌'
            all_passed=false
        fi

        printf -- '| %s | %s |\n' "$name" "$symbol" >>"$output"
    done

    all_passed_flag=$all_passed
}

write_summary() {
    local pattern total failed passed
    pattern='^(##|\| Test \| Status \||\| ---- \| ------ \||$)'
    mapfile -t lines < <(grep -vE "$pattern" "$output")
    total=${#lines[@]}
    failed=0
    for line in "${lines[@]}"; do
        [[ "$line" == *'❌'* ]] && ((failed++))
    done
    passed=$((total - failed))

    {
        printf -- '\n### Statistical Summary\n\n'
        printf -- '- **Total tests:** %d\n' "$total"
        printf -- '- **Passed:**      %d ✅\n' "$passed"
        printf -- '- **Failed:**      %d ❌\n' "$failed"
        printf -- '\n### Environment Information\n\n'
        printf -- '- **Ansible Version:** %s\n' "${ANSIBLE_VERSION:-Unknown}"
        printf -- '- **Build Date:** %s\n' "$(date -u)"
        printf -- '- **GitHub Run ID:** %s\n' "${GITHUB_RUN_ID:-Unknown}"
    } >>"$output"
}

main() {
    if (($# < 1)); then
        echo "Error: At least one test status required."
        exit 1
    fi

    write_header
    process_tests "$@"
    write_summary

    local status_symbol status_text
    if $all_passed_flag; then
        status_symbol='✅'
        status_text='SUCCESS'
    else
        status_symbol='❌'
        status_text='FAILED'
    fi

    sed -i "1s/.*/## Ansible Container Tests Summary — ${status_symbol} ${status_text}/" "$output"

    echo "Test summary generated at $output"
}

main "$@"
exit 0
