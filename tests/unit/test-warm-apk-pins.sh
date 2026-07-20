#!/usr/bin/env bash
#
# Description: Self-check for .github/scripts/warm-apk-pins.sh — verifies pin
#              extraction and URL planning against the real Dockerfile. Both
#              run offline; the network path is exercised by the nightly itself.
# Usage:       ./test-warm-apk-pins.sh
# Exit Code:   0 when all assertions pass, 1 otherwise
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
WARM_SCRIPT="${REPO_ROOT}/.github/scripts/warm-apk-pins.sh"

failures=0

assert_eq() {
    local expected="$1" actual="$2" message="$3"

    if [ "$expected" = "$actual" ]; then
        printf 'ok   %s\n' "$message"
    else
        printf 'FAIL %s\n     expected: %s\n     actual:   %s\n' \
            "$message" "$expected" "$actual"
        failures=$((failures + 1))
    fi
}

assert_contains() {
    local haystack="$1" needle="$2" message="$3"

    if printf '%s\n' "$haystack" | grep -qxF "$needle"; then
        printf 'ok   %s\n' "$message"
    else
        printf 'FAIL %s\n     missing: %s\n' "$message" "$needle"
        failures=$((failures + 1))
    fi
}

pins="$("$WARM_SCRIPT" --list)"
urls="$("$WARM_SCRIPT" --dry-run)"
version="$("$WARM_SCRIPT" --alpine-version)"

# --- Extraction ------------------------------------------------------------

# Both apk add blocks: 14 in builder + 15 in production = 29 raw, minus the 5
# pinned in both (curl, git, rsync, openssh-client-common, openssh-client-default)
# = 24 unique. A drop here means a pin stopped being warmed.
assert_eq 24 "$(printf '%s\n' "$pins" | sort -u | wc -l | tr -d ' ')" \
    'extracts 24 unique pins'

# The script must emit each pin once. Without dedup the 5 shared pins are
# fetched twice a night — harmless but pointless, and it desyncs the 96-URL
# budget the workflow step is sized against.
assert_eq "$(printf '%s\n' "$pins" | sort -u | wc -l | tr -d ' ')" \
    "$(printf '%s\n' "$pins" | wc -l | tr -d ' ')" \
    'pins are deduplicated'

# curl is the package this whole mechanism exists for; openssl is the last pin
# of the production block, which a naive `\`-only match drops.
assert_contains "$pins" 'curl-8.21.0-r0' 'includes curl (the pin that broke)'
assert_contains "$pins" 'openssl-3.5.7-r0' 'includes openssl (last pin in block)'
assert_contains "$pins" 'python3-3.14.5-r0' 'includes python3'
assert_contains "$pins" 'helm-3.19.0-r7' 'includes helm (community branch)'

malformed="$(printf '%s\n' "$pins" | grep -vE '^[a-z0-9][a-z0-9._+-]*-[0-9][^[:space:]]*$' || true)"
assert_eq '' "$malformed" 'every pin is well-formed'

# ENV USER=ansible and ARG VCS_REF="" match a naive name=value pattern and would
# be fetched as packages if the block boundaries ever stopped holding. Anchored
# to the full name: a bare `^PIPX` prefix also matches the real `pipx` pin.
leaked="$(printf '%s\n' "$pins" | grep -iE '^(USER|GROUP|UID|GID|VCS_REF|BUILD_DATE|ANSIBLE_VERSION|TARGETPLATFORM|PIPX_HOME|PIPX_BIN_DIR|PATH)-' || true)"
assert_eq '' "$leaked" 'no ENV/ARG values leak into the pin list'

# --- Version derivation ----------------------------------------------------

# Bound to the current base image: a Renovate bump of the FROM pin needs this
# line updated in the same PR. That coupling is the point — it proves the
# version is really derived from the Dockerfile and not hardcoded.
assert_eq 'v3.24' "$version" 'derives Alpine branch from the FROM pin'

# --- URL planning ----------------------------------------------------------

# 24 pins x 2 branches x 2 arches.
assert_eq 96 "$(printf '%s\n' "$urls" | sort -u | wc -l | tr -d ' ')" \
    'plans 96 unique URLs'

assert_eq 48 "$(printf '%s\n' "$urls" | grep -c '/x86_64/')" 'covers x86_64'
assert_eq 48 "$(printf '%s\n' "$urls" | grep -c '/aarch64/')" 'covers aarch64'
assert_eq 48 "$(printf '%s\n' "$urls" | grep -c '/main/')" 'covers the main branch'
assert_eq 48 "$(printf '%s\n' "$urls" | grep -c '/community/')" 'covers the community branch'

assert_contains "$urls" \
    'https://pkg.arillso.io/alpine/v3.24/main/x86_64/curl-8.21.0-r0.apk' \
    'builds a complete, correct URL'

malformed_urls="$(printf '%s\n' "$urls" | grep -vE '^https://pkg\.arillso\.io/alpine/v[0-9]+\.[0-9]+/(main|community)/(x86_64|aarch64)/[a-z0-9][a-z0-9._+-]*-[0-9][^[:space:]]*\.apk$' || true)"
assert_eq '' "$malformed_urls" 'every URL is well-formed'

# --- Failure modes ---------------------------------------------------------

# An empty extraction must not exit green: a silently no-op warming step would
# let the cache expire unnoticed, which is the failure this script prevents.
empty_dockerfile="$(mktemp)"
trap 'rm -f "$empty_dockerfile"' EXIT
printf 'FROM alpine:3.24.1\nRUN echo no pins here\n' >"$empty_dockerfile"

if DOCKERFILE="$empty_dockerfile" "$WARM_SCRIPT" --list >/dev/null 2>&1; then
    printf 'FAIL exits non-zero when no pins are found\n'
    failures=$((failures + 1))
else
    printf 'ok   exits non-zero when no pins are found\n'
fi

# A Dockerfile without a parseable FROM must fail rather than warm a guessed
# branch.
printf 'FROM ubuntu:24.04\nRUN apk add --no-cache curl=8.21.0-r0\n' >"$empty_dockerfile"

if DOCKERFILE="$empty_dockerfile" "$WARM_SCRIPT" --alpine-version >/dev/null 2>&1; then
    printf 'FAIL exits non-zero when the Alpine version is not derivable\n'
    failures=$((failures + 1))
else
    printf 'ok   exits non-zero when the Alpine version is not derivable\n'
fi

# --- Result ----------------------------------------------------------------

if [ "$failures" -gt 0 ]; then
    printf '\n%s assertion(s) failed\n' "$failures"
    exit 1
fi

printf '\nAll assertions passed\n'
