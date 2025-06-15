# Container: Ansible

[![License: MIT](https://img.shields.io/github/license/arillso/docker.ansible?style=popout-square)](LICENSE)
[![Comprehensive Tests](https://github.com/arillso/docker.ansible/actions/workflows/comprehensive-test.yml/badge.svg)](
https://github.com/arillso/docker.ansible/actions/workflows/comprehensive-test.yml)
[![Container Lint](https://github.com/arillso/docker.ansible/actions/workflows/container-lint.yml/badge.svg)](
https://github.com/arillso/docker.ansible/actions/workflows/container-lint.yml)
[![Docker Hub](https://img.shields.io/docker/pulls/arillso/ansible?style=popout-square)](
https://hub.docker.com/r/arillso/ansible)
[![Security Rating](https://img.shields.io/badge/security-A+-brightgreen?style=popout-square)](
https://github.com/arillso/docker.ansible/security)

## Overview

This is a lightweight, Alpine Linux–based container that provides an isolated environment for running Ansible. It uses a
Python virtual environment along with [pipx](https://github.com/pipxproject/pipx) to manage dependencies. This setup
makes the container ideal for CI/CD pipelines and portable Ansible deployments.

**Key Features:**
- ✅ **Mitogen enabled by default** for 2-7x faster execution
- ✅ **YAML inventory** with localhost pre-configured
- ✅ **Multi-platform support** (amd64, arm64)
- ✅ **Security-hardened** Alpine Linux base
- ✅ **Kubernetes tools** included (kubectl, helm, kustomize)

## Usage

### Quick Start

To check the installed Ansible version:

```bash
docker run --rm arillso/ansible ansible-playbook --version
```

### Running Playbooks

Mount your playbook directory and run Ansible:

```bash
docker run --rm -v $(pwd):/workspace -w /workspace arillso/ansible ansible-playbook playbook.yml
```

### Interactive Shell

For development and debugging:

```bash
docker run --rm -it -v $(pwd):/workspace -w /workspace arillso/ansible bash
```

### Custom Inventory

The container comes with a YAML inventory pre-configured for localhost. To use your own inventory:

```bash
# Using custom inventory file
docker run --rm -v $(pwd):/workspace -w /workspace arillso/ansible ansible-playbook -i inventory.yml playbook.yml

# Using dynamic inventory
docker run --rm -v $(pwd):/workspace -w /workspace arillso/ansible ansible-playbook -i inventory/ playbook.yml
```

### Available Tools

This container includes:
- **Ansible Core**: Latest stable version with Mitogen optimization
- **Kubernetes Tools**: kubectl, helm, kustomize
- **Cloud Support**: Docker, OpenShift clients
- **Security**: SSH, GPG, SSL tools
- **Utilities**: jq, curl, rsync, git

## Performance Features

This container includes **Mitogen** which is **enabled by default** for significantly faster Ansible execution:

- **2-7x faster** playbook execution
- **Reduced memory usage** on target hosts
- **Better connection pooling** for multi-host deployments
- **SSH pipelining** enabled for additional speed
- **Reliable output formatting** with default callback

### Performance is automatic

No configuration needed! Mitogen is pre-configured and ready to use:

```bash
# This automatically uses Mitogen for faster execution
docker run --rm -v $(pwd):/workspace -w /workspace arillso/ansible ansible-playbook playbook.yml
```

### Disabling Mitogen (if needed)

To use the standard linear strategy instead:

```bash
docker run --rm -e ANSIBLE_STRATEGY=linear -v $(pwd):/workspace arillso/ansible ansible-playbook playbook.yml
```

## Container Configuration

### Default Inventory

The container includes a pre-configured YAML inventory:

```yaml
all:
  hosts:
    localhost:
      ansible_connection: local
      ansible_python_interpreter: /pipx/venvs/ansible/bin/python3
```

### Ansible Configuration

Key settings in `/etc/ansible/ansible.cfg`:
- Mitogen strategy enabled by default
- Host key checking disabled
- SSH pipelining enabled
- Inventory points to `/etc/ansible/hosts.yml`

## Build from Source

If you prefer to build the container image yourself, you can do so using the provided Makefile. This command
automatically extracts the necessary information from the `requirements.txt` file.

To build the image locally, run:

```bash
make ansible-build
```

This command will:

- Read the Ansible dependency information from `requirements.txt`
- Build the container image based on the Dockerfile provided
- Tag the image as `ansible:latest`

## Registry Availability

The image is available on multiple registries:

- **GitHub Container Registry:**

  ```bash
  docker pull ghcr.io/arillso/ansible
  ```

- **Docker Hub:**

  ```bash
  docker pull arillso/ansible
  ```

## Testing

Run comprehensive tests locally:

```bash
make comprehensive-test
```

This includes:
- Structure tests for container integrity
- Security scans with Trivy
- Performance benchmarks
- Integration tests with Docker Compose
- Unit tests for Python components

## Contributing

Contributions are welcome! Here's how you can get involved:

- **Report Issues:** If you find any bugs or have suggestions for improvements, please open an issue on
  [GitHub Issues](https://github.com/arillso/docker.ansible/issues).
- **Submit Pull Requests:** Feel free to fork the repository, make your changes, and submit a pull request. Please
  ensure your changes adhere to our coding standards.
- **Documentation:** If you have ideas for additional documentation or enhancements, please share them in an issue or
  via a pull request.
- **Stay Updated:** Follow the repository to keep up with new releases and updates.

For more detailed guidelines, please refer to the [CONTRIBUTING.md](CONTRIBUTING.md) file.

## Further Information

- **Changelog:** A detailed version history can be found in the [CHANGELOG.md](CHANGELOG.md).
- **Source Code:** The complete project is hosted on [GitHub](https://github.com/arillso/docker.ansible).
- **Documentation:** Additional instructions and documentation are available in the repository.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for full details.

## Copyright

© 2020 – 2025, Arillso
