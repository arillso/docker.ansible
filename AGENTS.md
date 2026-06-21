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

- Use unpinned Alpine packages, or pin to a registry other than pkg.arillso.io (exact pins are only safe because the proxy retains old -rN releases; the renovate.json customManager keeps them current)
- Run as root in production
- Disable Mitogen without reason
- Skip security scans before release
