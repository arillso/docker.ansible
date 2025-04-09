# Container: Ansible

[![License: MIT](https://img.shields.io/github/license/arillso/docker.ansible?style=popout-square)](LICENSE)

## Overview

This is a lightweight, Alpine Linux–based container that provides an isolated environment for running Ansible. It uses a
Python virtual environment along with [pipx](https://github.com/pipxproject/pipx) to manage dependencies. This setup
makes the container ideal for CI/CD pipelines and portable Ansible deployments.

## Usage

To check the installed Ansible version, simply run:

```bash
docker run --rm arillso/ansible ansible-playbook --version
```

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

## Availability

The image is available on multiple registries:

- **GitHub Container Registry:**

  ```bash
  docker pull ghcr.io/arillso/ansible
  ```

- **Docker Hub:**

  ```bash
  docker pull arillso/ansible
  ```

## Contributing

Contributions are welcome! Here’s how you can get involved:

- **Report Issues:** If you find any bugs or have suggestions for improvements, please open an issue on
  [GitHub Issues](https://github.com/arillso/docker.ansible/issues).
- **Submit Pull Requests:** Feel free to fork the repository, make your changes, and submit a pull request. Please
  ensure your changes adhere to our coding standards.
- **Documentation:** If you have ideas for additional documentation or enhancements, please share them in an issue or
  via a pull request.
- **Stay Updated:** Follow the repository to keep up with new releases and updates.

For more detailed guidelines, please refer to the [CONTRIBUTING.md](CONTRIBUTING.md) file if available.

## Further Information

- **Changelog:** A detailed version history can be found in the [CHANGELOG.md](CHANGELOG.md).
- **Source Code:** The complete project is hosted on [GitHub](https://github.com/arillso/docker.ansible).
- **Documentation:** Additional instructions and documentation are available in the repository.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for full details.

## Copyright

© 2020 – 2025, Arillso
