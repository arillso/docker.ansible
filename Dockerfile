# syntax=docker/dockerfile:1@sha256:87999aa3d42bdc6bea60565083ee17e86d1f3339802f543c0d03998580f9cb89

##############################################
# Base Stage: Common configuration
##############################################
FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS base

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

# Point apk at the pkg.arillso.io caching proxy for the exact pins below. This
# is the BUILDER stage — it never ships, so the proxy URL stays local to the
# build. The proxy is a pull-through cache, not an archive — it evicts .apk
# files unread for 21 days, and Alpine rotates old -rN releases off dl-cdn.
# What keeps these pins resolvable is the nightly warm-apk-pins.sh step, not
# the proxy itself. Pins are auto-bumped by the customManager in
# .github/renovate.json (no per-package markers).
RUN alpine_minor="v$(cut -d'.' -f1-2 /etc/alpine-release)" && \
	printf 'https://pkg.arillso.io/alpine/%s/main\nhttps://pkg.arillso.io/alpine/%s/community\n' \
		"$alpine_minor" "$alpine_minor" > /etc/apk/repositories && \
	apk add --no-cache \
	py3-pip=26.1.2-r0 \
	pipx=1.14.0-r0 \
	ca-certificates=20260611-r0 \
	git=2.54.0-r0 \
	gcc=15.2.0-r5 \
	libffi-dev=3.5.2-r1 \
	python3-dev=3.14.5-r0 \
	make=4.4.1-r4 \
	musl-dev=1.2.6-r2 \
	build-base=0.5-r4 \
	openssh-client-common=10.3_p1-r0 \
	openssh-client-default=10.3_p1-r0 \
	rsync=3.4.3-r1 \
	curl=8.21.0-r0

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

# Install all runtime dependencies in a single layer. Exact apk pins
# auto-bumped by Renovate (see .github/renovate.json), resolved through the
# pkg.arillso.io proxy configured inline in this RUN, then reset to the
# public mirrors so the shipped image does not depend on the proxy.
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN alpine_minor="v$(cut -d'.' -f1-2 /etc/alpine-release)" && \
	printf 'https://pkg.arillso.io/alpine/%s/main\nhttps://pkg.arillso.io/alpine/%s/community\n' \
		"$alpine_minor" "$alpine_minor" > /etc/apk/repositories && \
	apk add --no-cache \
	python3=3.14.5-r0 \
	bash=5.3.9-r1 \
	git=2.54.0-r0 \
	curl=8.21.0-r0 \
	openssh-client-common=10.3_p1-r0 \
	openssh-client-default=10.3_p1-r0 \
	openssh-keygen=10.3_p1-r0 \
	sshpass=1.10-r0 \
	rsync=3.4.3-r1 \
	kubectl=1.36.1-r0 \
	helm=3.19.0-r7 \
	kustomize=5.8.1-r2 \
	jq=1.8.1-r0 \
	gnupg=2.4.9-r1 \
	openssl=3.5.7-r0 && \
	# Reset to the public Alpine mirrors so the SHIPPED image does not depend
	# on the private build-time proxy — downstream `apk add` uses dl-cdn.
	printf 'https://dl-cdn.alpinelinux.org/alpine/%s/main\nhttps://dl-cdn.alpinelinux.org/alpine/%s/community\n' \
		"$alpine_minor" "$alpine_minor" > /etc/apk/repositories && \
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
	# host_key_checking is disabled because this image targets ephemeral
	# CI/automation runs against freshly provisioned, short-lived hosts
	# whose host keys are not known ahead of time and would otherwise abort
	# the first connection. Override at runtime (ANSIBLE_HOST_KEY_CHECKING=True
	# or a mounted ansible.cfg) when connecting to persistent, trusted hosts.
	echo 'host_key_checking = False' >> /etc/ansible/ansible.cfg && \
	echo "strategy_plugins = $(/pipx/venvs/ansible/bin/python3 -c 'import os, ansible_mitogen.plugins.strategy as s; print(os.path.dirname(s.__file__))')" >> /etc/ansible/ansible.cfg && \
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
