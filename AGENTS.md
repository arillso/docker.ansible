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

- Alpine packages use `>=` lower-bound pins (`pkg>=version-rN`), resolved through the pkg.arillso.io caching proxy and bumped by Renovate (the shared `renovate-alpine` preset detects every `apk add` pin via repology — no per-package markers). Lower bounds tolerate Alpine's -rN rotation: the proxy is a pull-through cache, not an archive, so exact pins break on rebuild once an old -rN drops from dl-cdn
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

- Use unpinned Alpine packages, or pin to a registry other than pkg.arillso.io (the shared `renovate-alpine` preset keeps the lower bounds current)
- Replace the `>=` lower bounds with exact `=` pins, or drop the lower bound entirely — `>=` is deliberate so Alpine's -rN rotation cannot break the build
- Add an upper bound to the Alpine pins — the earlier upper-bound experiment (py3-pip, python3-dev) just recreated the drift pain from the other direction
- Run as root in production
- Disable Mitogen without reason
- Skip security scans before release
