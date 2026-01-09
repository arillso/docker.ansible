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

- Alpine packages use version ranges (e.g., `>=3.12.0`, `<4.0.0`)
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

- Pin Alpine packages to exact patch versions
- Run as root in production
- Disable Mitogen without reason
- Skip security scans before release
