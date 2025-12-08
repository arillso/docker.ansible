# syntax=docker/dockerfile:1@sha256:b6afd42430b15f2d2a4c5a02b919e98a525b785b1aaff16747d2f623364e39b6

##############################################
# Base Stage: Common configuration
##############################################
FROM alpine:3.23.0@sha256:51183f2cfa6320055da30872f211093f9ff1d3cf06f39a0bdb212314c5dc7375 AS base

# Define OCI labels for all stages
ARG BUILD_DATE
ARG ANSIBLE_VERSION
ARG VCS_REF=""
ARG TARGETPLATFORM=""

LABEL org.opencontainers.image.created="${BUILD_DATE}" \
	org.opencontainers.image.authors="Simon Baerlocher <s.baerlocher@sbaerlocher.ch>" \
	org.opencontainers.image.vendor="arillso" \
	org.opencontainers.image.licenses="MIT" \
	org.opencontainers.image.url="https://github.com/arillso/docker.ansible" \
	org.opencontainers.image.documentation="https://github.com/arillso/docker.ansible" \
	org.opencontainers.image.source="https://github.com/arillso/docker.ansible" \
	org.opencontainers.image.ref.name="Ansible ${ANSIBLE_VERSION}" \
	org.opencontainers.image.title="Ansible ${ANSIBLE_VERSION}" \
	org.opencontainers.image.description="Ansible ${ANSIBLE_VERSION} container image" \
	org.opencontainers.image.version="${ANSIBLE_VERSION}" \
	org.opencontainers.image.revision="${VCS_REF}" \
	org.opencontainers.image.architecture="${TARGETPLATFORM}"

# Common environment variables
ENV PIPX_HOME=/pipx \
	PIPX_BIN_DIR=/pipx/bin \
	PATH=/pipx/bin:$PATH

##############################################
# Builder Stage
##############################################
FROM base AS builder

WORKDIR /home

# Copy dependencies
COPY requirements.txt /requirements.txt

# Install all build dependencies in a single layer to reduce image size
RUN apk update && \
	apk add --no-cache \
	'py3-pip>=25.1.0' \
	'py3-pip<26.0.0' \
	'pipx>=1.7.0' \
	'pipx<2.0.0' \
	'ca-certificates>=20250619' \
	'ca-certificates<20260000' \
	'git>=2.49.0' \
	'git<3.0.0' \
	# Compiler toolchain - allow patch updates
	'gcc>=14.2.0' \
	'gcc<15.0.0' \
	'libffi-dev>=3.4.0' \
	'libffi-dev<4.0.0' \
	'python3-dev>=3.12.0' \
	'python3-dev<3.13.0' \
	'make>=4.4.0' \
	'make<5.0.0' \
	'musl-dev>=1.2.0' \
	'musl-dev<2.0.0' \
	'build-base>=0.5' \
	'build-base<1.0' \
	# Network and SSH tools
	'openssh-client-common>=10.0' \
	'openssh-client-common<11.0' \
	'openssh-client-default>=10.0' \
	'openssh-client-default<11.0' \
	'rsync>=3.4.0' \
	'rsync<4.0.0' \
	'curl>=8.14.0' \
	'curl<9.0.0'

# Create virtual environment and install dependencies
RUN	python3 -m venv /pipx/venvs/ansible && \
	/pipx/venvs/ansible/bin/pip install --upgrade pip --no-cache-dir && \
	/pipx/venvs/ansible/bin/pip install --no-cache-dir -r /requirements.txt && \
	mkdir -p /pipx/bin && \
	for file in /pipx/venvs/ansible/bin/*; do \
	ln -sf "$file" "/pipx/bin/$(basename "$file")"; \
	done && \
	# Cleanup
	rm -rf /var/cache/apk/* /tmp/*

##############################################
# Production Stage
##############################################
FROM base AS production

# User parameters
ENV USER=ansible \
	GROUP=ansible \
	UID=1000 \
	GID=1000

WORKDIR /home/ansible

# Install all runtime dependencies in a single layer
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v$(cut -d'.' -f1-2 /etc/alpine-release)/community" >> /etc/apk/repositories && \
	apk update && \
	apk add --no-cache \
	# Base packages - conservative ranges
	'python3>=3.12.0' \
	'python3<3.13.0' \
	'bash>=5.2.0' \
	'bash<5.3.0' \
	# VCS and networking
	'git>=2.49.0' \
	'git<3.0.0' \
	'curl>=8.14.0' \
	'curl<9.0.0' \
	# SSH tools - security critical, allow patch updates
	'openssh-client-common>=10.0' \
	'openssh-client-common<11.0' \
	'openssh-client-default>=10.0' \
	'openssh-client-default<11.0' \
	'openssh-keygen>=10.0' \
	'openssh-keygen<11.0' \
	'sshpass>=1.10' \
	'sshpass<2.0' \
	# File synchronization
	'rsync>=3.4.0' \
	'rsync<4.0.0' \
	# Kubernetes tools - allow minor updates
	'kubectl>=1.33.0' \
	'kubectl<1.34.0' \
	'helm>=3.18.0' \
	'helm<4.0.0' \
	'kustomize>=5.6.0' \
	'kustomize<6.0.0' \
	# Utilities
	'jq>=1.8.0' \
	'jq<2.0.0' \
	# Security packages - allow patch updates
	'gnupg>=2.4.0' \
	'gnupg<3.0.0' \
	'openssl>=3.5.0' \
	'openssl<4.0.0' && \
	# User setup
	addgroup -g ${GID} ${GROUP} && \
	adduser -h /home/ansible -s /bin/bash -G ${GROUP} -D -u ${UID} ${USER} && \
	ln -sf /usr/bin/python3 /usr/bin/python && \
	mkdir -p /home/ansible/.gnupg /home/ansible/.ssh /data && \
	chown -R ${USER}:${GROUP} /home/ansible /data && \
	chmod 0700 /home/ansible/.gnupg /home/ansible/.ssh && \
	chmod 0755 /data && \
	rm -rf /var/cache/apk/* /tmp/*

# Copy pipx environment and create Ansible configuration
COPY --from=builder /pipx /pipx
RUN mkdir -p /etc/ansible && \
	echo 'all:' > /etc/ansible/hosts.yml && \
	echo '  hosts:' >> /etc/ansible/hosts.yml && \
	echo '    localhost:' >> /etc/ansible/hosts.yml && \
	echo '      ansible_connection: local' >> /etc/ansible/hosts.yml && \
	echo '      ansible_python_interpreter: /pipx/venvs/ansible/bin/python3' >> /etc/ansible/hosts.yml && \
	echo '[defaults]' > /etc/ansible/ansible.cfg && \
	echo 'inventory = /etc/ansible/hosts.yml' >> /etc/ansible/ansible.cfg && \
	echo 'host_key_checking = False' >> /etc/ansible/ansible.cfg && \
	echo 'strategy_plugins = /pipx/venvs/ansible/lib/python3.12/site-packages/ansible_mitogen/plugins/strategy' >> /etc/ansible/ansible.cfg && \
	echo 'strategy = mitogen_linear' >> /etc/ansible/ansible.cfg && \
	echo 'stdout_callback = default' >> /etc/ansible/ansible.cfg && \
	echo 'pipelining = True' >> /etc/ansible/ansible.cfg && \
	rm -rf /tmp/*

# Use non-root user
USER ${USER}
ENV ANSIBLE_FORCE_COLOR=True

# Default command
CMD ["ansible-playbook", "--version"]

# Healthcheck to verify Ansible functionality
HEALTHCHECK --interval=30s --timeout=10s CMD ansible --version || exit 1
