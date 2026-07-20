#!/usr/bin/env bash
#
# Description: Keep the pkg.arillso.io cache warm for the exact apk pins in the
#              Dockerfile, and verify every pin is still resolvable.
#
#              The cache-evict sidecar in front of the proxy deletes *.apk files
#              that nobody has read for 21 days (atime). A CI build does not read
#              them: every workflow uses cache-from, so a cache-hit on the
#              `RUN ... apk add ...` layer means the command never runs and no
#              request reaches the proxy. That layer is only invalidated when
#              Renovate bumps a pin inside it — so packages *without* a new
#              upstream release are the ones that fall out of the cache first,
#              and the next real build 404s against dl-cdn (Alpine rotates old
#              -rN releases away). Fetching each pin here, outside Docker, keeps
#              atime fresh and fails loudly while there is still time to react.
#
# Usage:       ./warm-apk-pins.sh [--list] [--alpine-version] [--dry-run]
#                --list             print `name-version` for every pin, one per line
#                --alpine-version   print the Alpine branch (e.g. v3.24)
#                --dry-run          print the URLs that would be fetched
#              With no flag, fetch every URL and report unresolvable pins.
# Exit Code:   0 when every pin resolved, 1 otherwise
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKERFILE="${DOCKERFILE:-${SCRIPT_DIR}/../../Dockerfile}"
PROXY="${PROXY:-https://pkg.arillso.io}"

# Alpine's repository layout splits packages across main and community, and the
# Dockerfile does not record which pin lives where. Trying both and accepting a
# single hit is cheaper than maintaining that mapping by hand.
BRANCHES=(main community)
# merge.yml builds amd64 and arm64. Warming only the arch the nightly happens to
# build would let the other one rot until the release build breaks.
ARCHES=(x86_64 aarch64)

# Derive the Alpine branch from the FROM pin rather than hardcoding it, so a
# base image bump does not silently warm the wrong (still-populated) branch
# while the pins the build actually needs expire.
alpine_version() {
    local version
    version="$(sed -n 's/^FROM alpine:\([0-9][0-9]*\.[0-9][0-9]*\).*/v\1/p' "$DOCKERFILE" | head -n 1)"

    if [ -z "$version" ]; then
        echo "::error::Could not derive the Alpine version from ${DOCKERFILE} (expected a line like 'FROM alpine:3.24.1@sha256:...')" >&2
        return 1
    fi

    printf '%s\n' "$version"
}

# Extract every `name=version-rN` pin from the `apk add` blocks.
#
# Block-delimited on purpose: a repo-wide match for `name=value` also picks up
# `ENV USER=ansible` and `ARG VCS_REF=""`, which would then be fetched as
# packages. A block ends at the first line that does not continue the shell
# command, which is why the trailing separator is stripped *before* matching —
# the last pin of the production block ends in ` && \`, not ` \`, and a naive
# pattern drops it (that is openssl, one silently missing pin).
list_pins() {
    awk '
        /apk add --no-cache/ { in_block = 1; next }
        !in_block { next }
        {
            line = $0
            sub(/^[[:space:]]+/, "", line)
            sub(/[[:space:]]*&&[[:space:]]*\\$/, "", line)
            sub(/[[:space:]]*\\$/, "", line)
            sub(/[[:space:]]+$/, "", line)

            if (line ~ /^[a-z0-9][a-z0-9._+-]*=[0-9][^[:space:]]*$/) {
                sub(/=/, "-", line)

                # Five packages (curl, git, rsync, both openssh-client-*) are
                # pinned in both the builder and the production block. Warming
                # them once per block would double those requests for no gain.
                if (!(line in seen)) {
                    seen[line] = 1
                    print line
                }

                next
            }

            in_block = 0
        }
    ' "$DOCKERFILE"
}

# Build the full URL set without touching the network, so the plan stays
# testable offline.
plan_urls() {
    local alpine_version="$1"
    local pin branch arch

    while IFS= read -r pin; do
        for branch in "${BRANCHES[@]}"; do
            for arch in "${ARCHES[@]}"; do
                printf '%s/alpine/%s/%s/%s/%s.apk\n' \
                    "$PROXY" "$alpine_version" "$branch" "$arch" "$pin"
            done
        done
    done
}

# GET, not HEAD: pkgproxy only writes to its cache when bytes are actually
# streamed (rw.bytesWritten > 0), so a HEAD would report success on a miss
# without populating anything. GET makes this self-healing for pins added since
# the last run. Output is discarded — only the status code matters.
fetch_pins() {
    local alpine_version="$1"
    local pin branch arch url failed=0 resolved

    while IFS= read -r pin; do
        for arch in "${ARCHES[@]}"; do
            resolved=0

            for branch in "${BRANCHES[@]}"; do
                url="${PROXY}/alpine/${alpine_version}/${branch}/${arch}/${pin}.apk"

                # No --show-error: main is always tried first, so every
                # community-only package (helm, kubectl, …) would log a 404 per
                # run even though the fallback succeeds. Real failures are
                # reported below with the package and arch.
                if curl --fail --silent --location \
                    --max-time 60 --output /dev/null "$url"; then
                    resolved=1
                    break
                fi
            done

            if [ "$resolved" -eq 0 ]; then
                echo "::error::Pin ${pin} (${arch}) is not resolvable in any branch of Alpine ${alpine_version} — the next build of this image will fail" >&2
                failed=1
            fi
        done
    done

    return "$failed"
}

main() {
    local mode="${1:---fetch}"
    local version pins

    version="$(alpine_version)"

    if [ "$mode" = "--alpine-version" ]; then
        printf '%s\n' "$version"
        return 0
    fi

    pins="$(list_pins)"

    # An empty extraction would make every mode below a no-op that still exits
    # green — the step would silently stop warming anything. Fail instead.
    if [ -z "$pins" ]; then
        echo "::error::No apk pins found in ${DOCKERFILE} — the extraction is broken or the Dockerfile changed shape" >&2
        return 1
    fi

    case "$mode" in
    --list)
        printf '%s\n' "$pins"
        ;;
    --dry-run)
        printf '%s\n' "$pins" | plan_urls "$version"
        ;;
    --fetch)
        printf '%s\n' "$pins" | fetch_pins "$version"
        ;;
    *)
        echo "::error::Unknown option: ${mode}" >&2
        return 1
        ;;
    esac
}

main "$@"
