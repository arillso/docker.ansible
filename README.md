# Ansible Container

Alpine-based Docker container for running Ansible with Mitogen optimization, Kubernetes tools, and multi-platform support.

## Quick Start

```bash
# Check Ansible version
docker run --rm arillso/ansible ansible-playbook --version

# Run a playbook
docker run --rm -v $(pwd):/workspace -w /workspace arillso/ansible ansible-playbook playbook.yml

# Interactive shell
docker run --rm -it -v $(pwd):/workspace -w /workspace arillso/ansible bash
```

## Features

- Mitogen enabled by default (2-7x faster execution)
- Kubernetes tools (kubectl, helm, kustomize)
- Multi-platform (amd64, arm64)
- Non-root user

## Registry

```bash
docker pull ghcr.io/arillso/ansible
docker pull arillso/ansible
```

## Build

```bash
make ansible-build
make comprehensive-test
```

## License

MIT License
