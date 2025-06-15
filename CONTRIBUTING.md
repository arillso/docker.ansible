# Contributing to docker.ansible

Thank you for your interest in contributing to this project!

## How to Contribute

### Reporting Issues
- Use GitHub Issues to report bugs or request features
- Include detailed reproduction steps for bugs
- Specify the Ansible and container versions you're using

### Development Setup
1. Fork the repository
2. Clone your fork locally
3. Make your changes
4. Test your changes using: `make comprehensive-test`
5. Submit a pull request

### Code Standards
- All Docker images must pass security scans
- Update requirements.txt when adding new dependencies
- Follow Alpine Linux best practices
- Add tests for new functionality

### Testing
Run the full test suite before submitting:
```bash
make comprehensive-test
```

### Documentation
- Update README.md for user-facing changes
- Update CHANGELOG.md following Keep a Changelog format
- Document new Makefile targets

### Release Process (Maintainers)
1. Update Ansible version in `requirements.txt`
2. Update `CHANGELOG.md` with new version entry
3. Run `make release-check` to validate readiness
4. Create and push a version tag: `git tag v2.18.6 && git push origin v2.18.6`
5. GitHub Actions will automatically create the release

### Code Quality Standards
- All code must pass MegaLinter checks
- Docker images must pass security scans (Trivy)
- Test coverage should be maintained
- Follow semantic commit conventions

### Dependency Updates
- Dependencies are automatically updated via Renovate and Dependabot
- Manual updates should follow the same testing process
- Group related dependency updates when possible

## Questions?
Open an issue for any questions about contributing.
