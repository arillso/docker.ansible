#!/usr/bin/env bash
#
# Description: Generate a markdown summary of container registry cleanup operations
# Usage:       ./cleanup-summary.sh <Registry1=status> [Registry2=status ...]
# Exit Code:   Always exits with 0 for workflow continuation
#

set -euo pipefail
IFS=$'\n\t'

declare -g all_passed_flag=true
declare -g output="./cleanup-report.md"

write_header() {
    printf -- '## Container Registry Cleanup Report\n\n' >"$output"
    printf -- 'Cleanup executed on: %s\n\n' "$(date -u)" >>"$output"
}

process_registries() {
    local all_passed=true

    printf -- '| Registry | Status |\n| -------- | ------ |\n' >>"$output"

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

write_policy_info() {
    {
        printf -- '\n### Retention Policies Applied\n\n'
        printf -- '- Commit hash tags (.*-[0-9a-f]{7}): 60 days\n'
        printf -- '- Untagged images (<none>): 60 days\n'
        printf -- '- Skipped tags: latest, main, version tags (vX.Y.Z)\n'
        printf -- '\n### Next Scheduled Run\n\n'
        printf -- '- Next cleanup scheduled for the first day of next month at 02:00 UTC\n'
    } >>"$output"
}

main() {
    if (($# < 1)); then
        echo "Error: At least one registry status required."
        exit 1
    fi

    write_header
    process_registries "$@"
    write_policy_info

    local status_symbol status_text
    if $all_passed_flag; then
        status_symbol='✅'
        status_text='SUCCESS'
    else
        status_symbol='❌'
        status_text='FAILED'
    fi

    sed -i "1s/.*/## Container Registry Cleanup Report — ${status_symbol} ${status_text}/" "$output"

    echo "Cleanup summary generated at $output"
}

main "$@"
exit 0
