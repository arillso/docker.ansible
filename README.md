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

## Environment Variables

The image needs no environment variables to run. The defaults below are baked
in; override them with `-e NAME=value` when needed.

| Variable                     | Default            | Purpose                                                              |
| ---------------------------- | ------------------ | -------------------------------------------------------------------- |
| `ANSIBLE_FORCE_COLOR`        | `True`             | Colored output even when stdout is not a TTY. Set `False` to disable. |
| `ANSIBLE_HOST_KEY_CHECKING`  | `False` (via cfg)  | Skips SSH host-key verification. Set `True` for persistent hosts.    |
| `ANSIBLE_CONFIG`             | `/etc/ansible/ansible.cfg` | Point to a mounted config to override the baked-in defaults. |
| `PIPX_HOME` / `PATH`         | `/pipx`            | Location of the Ansible virtualenv. Do not change.                  |

Common run-time inputs are passed by mounting, not env vars:

```bash
# SSH key and connecting to a remote host with host-key checking enabled
docker run --rm \
  -e ANSIBLE_HOST_KEY_CHECKING=True \
  -v $(pwd):/workspace -w /workspace \
  -v $HOME/.ssh/id_ed25519:/home/ansible/.ssh/id_ed25519:ro \
  arillso/ansible ansible-playbook -i inventory.yml playbook.yml

# Vault password via file
docker run --rm \
  -v $(pwd):/workspace -w /workspace \
  -v $(pwd)/.vault_pass:/home/ansible/.vault_pass:ro \
  arillso/ansible ansible-playbook --vault-password-file /home/ansible/.vault_pass playbook.yml
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
