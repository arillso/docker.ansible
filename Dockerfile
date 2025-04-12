# syntax=docker/dockerfile:1

##############################################
# Builder Stage: Build dependencies and create venv
##############################################
FROM alpine:3.21.3 AS builder

# Build-time arguments
ARG BUILD_DATE       # Build date for metadata
ARG ANSIBLE_VERSION  # Ansible version to use
ARG VCS_REF=""       # Source Control Revision (e.g. commit SHA)

# OCI metadata labels (including additional BuildKit labels)
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
	org.opencontainers.image.revision="${VCS_REF}"

# Note:
# For multi-arch images, you can adjust the description in the image manifest.
# Example annotation for multi-arch support:
# "annotations": {
#   "org.opencontainers.image.description": "My multi-arch image"
# }
# This can be configured during build time via CLI or CI/CD tools.

# Set pipx environment variables
ENV PIPX_HOME=/pipx \
	PIPX_BIN_DIR=/pipx/bin \
	PATH=/pipx/bin:$PATH

WORKDIR /home

# Copy dependency definitions
COPY requirements.txt /requirements.txt

# Update package index and install build dependencies (with fixed versions)
RUN apk update && \
	apk add --no-cache \
	python3=3.12.10-r0 \
	py3-pip=24.3.1-r0 \
	pipx=1.7.1-r0 \
	gcc=14.2.0-r4 \
	libffi-dev=3.4.7-r0 \
	python3-dev=3.12.10-r0 \
	make=4.4.1-r2 \
	musl-dev=1.2.5-r9 \
	ca-certificates=20241121-r1 \
	git=2.47.2-r0 \
	openssh-client-common=9.9_p2-r0 \
	openssh-client-default=9.9_p2-r0 \
	rsync=3.4.0-r0 \
	curl=8.12.1-r1 \
	build-base=0.5-r3

# Create Python virtual environment, install dependencies and link executables
RUN python3 -m venv /pipx/venvs/ansible && \
	/pipx/venvs/ansible/bin/pip install --upgrade pip --no-cache-dir && \
	/pipx/venvs/ansible/bin/pip install --no-cache-dir -r /requirements.txt && \
	mkdir -p /pipx/bin && \
	for file in /pipx/venvs/ansible/bin/*; do \
	ln -sf "$file" "/pipx/bin/$(basename "$file")"; \
	done && \
	rm -rf /var/cache/apk/* /tmp/*

##############################################
# Production Stage: Final runtime image
##############################################
FROM alpine:3.21.3 AS production

# Build-time arguments
ARG BUILD_DATE       # Build date for metadata
ARG ANSIBLE_VERSION  # Ansible version to use
ARG VCS_REF=""       # Source Control Revision

# OCI metadata labels (including multi-arch and additional BuildKit labels)
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
	org.opencontainers.image.revision="${VCS_REF}"

LABEL org.opencontainers.image.architecture="${TARGETPLATFORM}"


# Set runtime environment variables and user parameters
ENV PIPX_HOME=/pipx \
	PIPX_BIN_DIR=/pipx/bin \
	PATH=/pipx/bin:$PATH \
	USER=ansible \
	GROUP=ansible \
	UID=1000 \
	GID=1000

WORKDIR /home/ansible

# Add the community repository, update APK index, and install runtime dependencies (with fixed versions)
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.21/community" >> /etc/apk/repositories && \
	apk update && \
	apk add --no-cache \
	python3=3.12.10-r0 \
	kubectl=1.31.5-r2 \
	jq=1.7.1-r0 \
	helm=3.16.3-r4 \
	kustomize=5.5.0-r4 \
	bash=5.2.37-r0 \
	git=2.47.2-r0 \
	gnupg=2.4.7-r0 \
	openssh-client-common=9.9_p2-r0 \
	openssh-client-default=9.9_p2-r0 \
	openssh-keygen=9.9_p2-r0 \
	openssl=3.3.3-r0 \
	sshpass=1.10-r0 \
	rsync=3.4.0-r0 && \
	addgroup -g ${GID} ${GROUP} && \
	adduser -h /home/ansible -s /bin/bash -G ${GROUP} -D -u ${UID} ${USER} && \
	ln -sf /usr/bin/python3 /usr/bin/python && \
	mkdir -p /home/ansible/.gnupg /home/ansible/.ssh /data && \
	chown -R ${USER}:${GROUP} /home/ansible /data && \
	chmod 0700 /home/ansible/.gnupg /home/ansible/.ssh && \
	chmod 0755 /data && \
	rm -rf /var/cache/apk/* /tmp/*

# Copy pipx environment from builder stage
COPY --from=builder /pipx /pipx

# Create default Ansible configuration
RUN mkdir -p /etc/ansible && \
	echo 'localhost' > /etc/ansible/hosts && \
	rm -rf /tmp/*

# Switch to non-root user for runtime
USER ${USER}
ENV ANSIBLE_FORCE_COLOR=True

# Default command: display ansible-playbook version
CMD ["ansible-playbook", "--version"]

# Healthcheck to verify Ansible functionality
HEALTHCHECK --interval=30s --timeout=10s CMD ansible --version || exit 1
