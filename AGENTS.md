# Ansible Container

## Context

Alpine-based Docker container for running Ansible with Mitogen optimization. Published to ghcr.io/arillso/ansible and Docker Hub.

## Structure

```text
Dockerfile           # Multi-stage build (base, builder, production)
Makefile             # Build, test, and release commands
requirements.txt     # Python dependencies (ansible-core, mitogen)
tests/               # Unit, integration, security, performance tests
.github/workflows/   # CI/CD pipelines
```

## Conventions

- Alpine packages use exact pins (`pkg=version-rN`), resolved through the pkg.arillso.io caching proxy and bumped by Renovate (a customManager auto-detects every `apk add` pin via the repology datasource — no per-package markers)
- The proxy is a pull-through cache, **not** an archive: its evict sidecar deletes `.apk` files nobody has read for 21 days, and Alpine rotates old `-rN` releases off dl-cdn. A pinned package that stops being fetched therefore becomes unbuildable. `.github/scripts/warm-apk-pins.sh` runs nightly to keep every pin read (and to fail loudly if one is already gone) — a normal CI build does not, because `cache-from` means a layer hit never executes `apk add`
- Non-root user `ansible` (UID/GID 1000)
- Mitogen enabled by default for performance
- Multi-platform builds (amd64, arm64)

## Commands

```bash
make ansible-build       # Build container
make test-quick          # Quick validation
make comprehensive-test  # Full test suite
make release-check       # Pre-release validation
```

## Do Not

- Use unpinned Alpine packages, or pin to a registry other than pkg.arillso.io (the renovate.json customManager keeps the pins current)
- Remove the `Warm apk pin cache` step from `nightly-security.yml`, or make `warm-apk-pins.sh` tolerate an empty pin list or a failed fetch. It is the only thing that keeps pinned packages from being evicted from the proxy — silently degrading it reintroduces the exact failure it was written for, and the breakage surfaces weeks later in an unrelated build
- Run as root in production
- Disable Mitogen without reason
- Skip security scans before release
