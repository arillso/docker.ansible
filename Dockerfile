# syntax=docker/dockerfile:1@sha256:38387523653efa0039f8e1c89bb74a30504e76ee9f565e25c9a09841f9427b05

##############################################
# Base Stage: Common configuration
##############################################
FROM alpine:3.22.1@sha256:4bcff63911fcb4448bd4fdacec207030997caf25e9bea4045fa6c8c44de311d1 AS base

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
	# System packages
	py3-pip=25.1.1-r0 \
	pipx=1.7.1-r0 \
	ca-certificates=20250619-r0 \
	git=2.49.1-r0 \
	# Compiler toolchain
	gcc=14.2.0-r6 \
	libffi-dev=3.4.8-r0 \
	python3-dev=3.12.11-r0 \
	make=4.4.1-r3 \
	musl-dev=1.2.5-r10 \
	build-base=0.5-r3 \
	openssh-client-common=10.0_p1-r7 \
	openssh-client-default=10.0_p1-r7 \
	rsync=3.4.1-r0 \
	curl=8.14.1-r1
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
	# Base packages
	python3=3.12.11-r0 \
	bash=5.2.37-r0 \
	git=2.49.1-r0 \
	openssh-client-common=10.0_p1-r7 \
	openssh-client-default=10.0_p1-r7 \
	openssh-keygen=10.0_p1-r7 \
	sshpass=1.10-r0 \
	rsync=3.4.1-r0 \
	# Specific tools
	kubectl=1.33.1-r1 \
	jq=1.8.0-r0 \
	helm=3.18.4-r1 \
	kustomize=5.6.0-r5 \
	gnupg=2.4.7-r0 \
	openssl=3.5.1-r0 \
	curl=8.14.1-r1 && \
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
