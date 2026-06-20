# Code Review Guidelines

## Scope

In scope:

- `Dockerfile` changes (stages, package sets, version ranges)
- `requirements.txt` changes (ansible-core, mitogen, Python deps)
- Test changes (`tests/` — unit, integration, security, performance, structure, upgrade)
- CI/CD workflow changes
- Renovate configuration updates
- `Makefile` build/test targets

Out of scope:

- `test-results/` and `megalinter-reports/` — generated artifacts
- Renovate dependency-only PRs (patch/minor with automerge enabled)
- Generated changelog entries from release automation

## Required checks

- No secrets committed — no credentials, tokens, or keys in the image or build context
- `hadolint` passes on the Dockerfile
- yamllint passes
- Container structure tests pass (`make structure-test`)
- Security scans pass (gitleaks, secretlint, trivy)
- Image runs as the non-root `ansible` user (UID/GID 1000)
- Alpine packages use version ranges, never exact patch pins
- Build tools stay in the builder stage and out of the production image

## Severity levels

| Level        | Meaning                                             | Merge impact       |
| ------------ | --------------------------------------------------- | ------------------ |
| Bug          | Incorrect behavior or broken contract               | Blocks merge       |
| Nit          | Minor issue — suboptimal but not incorrect          | Non-blocking       |
| Pre-existing | Issue present before this PR; flagged for awareness | No action required |

## Skip

- Renovate PRs with `automerge: true` (patch/minor) after CI passes
- Documentation-only changes with no functional impact
