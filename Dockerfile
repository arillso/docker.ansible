# syntax=docker/dockerfile:1@sha256:9857836c9ee4268391bb5b09f9f157f3c91bb15821bb77969642813b0d00518d

##############################################
# Base Stage: Common configuration
##############################################
FROM alpine:3.22.0@sha256:8a1f59ffb675680d47db6337b49d22281a139e9d709335b492be023728e11715 AS base

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
	py3-pip=24.3.1-r0 \
	pipx=1.7.1-r0 \
	ca-certificates=20241121-r1 \
	git=2.47.2-r0 \
	# Compiler toolchain
	gcc=14.2.0-r4 \
	libffi-dev=3.4.7-r0 \
	python3-dev=3.12.11-r0 \
	make=4.4.1-r2 \
	musl-dev=1.2.5-r9 \
	build-base=0.5-r3 \
	openssh-client-common=9.9_p2-r0 \
	openssh-client-default=9.9_p2-r0 \
	rsync=3.4.0-r0 \
	curl=8.12.1-r1
# Create virtual environment and install dependencies
RUN python3 -m venv /pipx/venvs/ansible && \
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
	python3=3.12.10-r1 \
	bash=5.2.37-r0 \
	git=2.47.2-r0 \
	openssh-client-common=9.9_p2-r0 \
	openssh-client-default=9.9_p2-r0 \
	openssh-keygen=9.9_p2-r0 \
	sshpass=1.10-r0 \
	rsync=3.4.0-r0 \
	# Specific tools
	kubectl=1.31.5-r3 \
	jq=1.7.1-r0 \
	helm=3.16.3-r5 \
	kustomize=5.5.0-r5 \
	gnupg=2.4.7-r0 \
	openssl=3.3.3-r0 \
	curl=8.12.1-r1 && \
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
	echo 'localhost' > /etc/ansible/hosts && \
	rm -rf /tmp/*

# Use non-root user
USER ${USER}
ENV ANSIBLE_FORCE_COLOR=True

# Default command
CMD ["ansible-playbook", "--version"]

# Healthcheck to verify Ansible functionality
HEALTHCHECK --interval=30s --timeout=10s CMD ansible --version || exit 1
