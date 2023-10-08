# Use a base Alpine Linux image
FROM alpine:3.18.4 as builder

# Define build arguments for tool versions
ARG ANSIBLE_VERSION=2.15.4
ARG HELM_VERSION=3.13.0
ARG KUBECTL_VERSION=1.28.2
ARG KUSTOMIZE_VERSION=v5.1.1

# Set the working directory
WORKDIR /home

# Install common dependencies for building and runtime
RUN apk --update --no-cache add \
	gcc \
	libffi-dev \
	make \
	musl-dev \
	python3 \
	bc \
	ca-certificates \
	git \
	openssh-client \
	rsync \
	curl

# Install development dependencies in a separate virtual package
RUN apk --update --no-cache add --virtual \
	.build-deps \
	sshpass \
	python3-dev \
	libffi-dev \
	openssl-dev \
	build-base \
	py3-pip \
	py3-wheel \
	rust \
	cargo \
	libxml2 \
	libxslt-dev

# Copy requirements file and install Python packages
COPY requirements.txt /requirements.txt
RUN set -eux \
	&& pip3 install --upgrade -r /requirements.txt \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

# Install Ansible and cleanup Python cache
RUN set -eux \
	&& pip3 install --no-cache-dir ansible-core==${ANSIBLE_VERSION} \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

# Determine the architecture and set an environment variable
RUN case `uname -m` in \
	x86_64) ARCH=amd64; ;; \
	armv7l) ARCH=arm; ;; \
	aarch64) ARCH=arm64; ;; \
	ppc64le) ARCH=ppc64le; ;; \
	s390x) ARCH=s390x; ;; \
	*) echo "unsupported arch, exit ..."; exit 1; ;; \
	esac && \
	echo "export ARCH=$ARCH" > /envfile && \
	cat /envfile

# Install Helm
RUN . /envfile && echo $ARCH && \
	apk add --update --no-cache curl ca-certificates bash git && \
	curl -sL https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz | tar -xvz && \
	mv linux-${ARCH}/helm /usr/bin/helm && \
	chmod +x /usr/bin/helm && \
	rm -rf linux-${ARCH}

# Install kubectl
RUN . /envfile && echo $ARCH && \
	curl -sLO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl && \
	mv kubectl /usr/bin/kubectl && \
	chmod +x /usr/bin/kubectl

# Install Kustomize
RUN . /envfile && echo $ARCH && \
	curl -sLO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz && \
	tar xvzf kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz && \
	mv kustomize /usr/bin/kustomize && \
	chmod +x /usr/bin/kustomize && \
	rm kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz

# Create a new stage for the production image
FROM alpine:3.18.4 as production

# Define environment variables
ENV \
	USER=ansible \
	GROUP=ansible \
	UID=1000 \
	GID=1000

# Set Ansible version as an argument
ARG ANSIBLE_VERSION=2.15.4

# Set labels for the image
LABEL "maintainer"="Simon Baerlocher <s.baerlocher@sbaerlocher.ch>" \
	"org.opencontainers.image.authors"="Simon Baerlocher <s.baerlocher@sbaerlocher.ch>" \
	"org.opencontainers.image.vendor"="arillso" \
	"org.opencontainers.image.licenses"="MIT" \
	"org.opencontainers.image.url"="https://github.com/arillso/docker.ansible" \
	"org.opencontainers.image.documentation"="https://github.com/arillso/docker.ansible" \
	"org.opencontainers.image.source"="https://github.com/arillso/docker.ansible" \
	"org.opencontainers.image.ref.name"="Ansible ${ANSIBLE_VERSION}" \
	"org.opencontainers.image.title"="Ansible ${ANSIBLE_VERSION}" \
	"org.opencontainers.image.description"="Ansible ${ANSIBLE_VERSION}"

# Copy necessary files and binaries from the builder stage
COPY --from=builder /usr/lib/python3.11/site-packages/ /usr/lib/python3.11/site-packages/
COPY --from=builder /usr/bin/ansible /usr/bin/ansible
COPY --from=builder /usr/bin/ansible-connection /usr/bin/ansible-connection
COPY --from=builder /usr/bin/ansible-playbook /usr/bin/ansible-playbook
COPY --from=builder /usr/bin/ansible-galaxy /usr/bin/ansible-galaxy
COPY --from=builder /usr/bin/kustomize /usr/bin/kustomize
COPY --from=builder /usr/bin/kubectl /usr/bin/kubectl

# Create the ansible user and set up directories
RUN set -eux \
	&& addgroup -g ${GID} ${GROUP} \
	&& adduser -h /home/ansible -s /bin/bash -G ${GROUP} -D -u ${UID} ${USER} \
	\
	&& mkdir /home/ansible/.gnupg \
	&& chown ansible:ansible /home/ansible/.gnupg \
	&& chmod 0700 /home/ansible/.gnupg \
	\
	&& mkdir /home/ansible/.ssh \
	&& chown ansible:ansible /home/ansible/.ssh \
	&& chmod 0700 /home/ansible/.ssh \
	\
	&& mkdir /data \
	&& chown ansible:ansible /data \
	&& chmod 0755 /data \
	\
	&& apk add --no-cache \
	bash \
	git \
	gnupg \
	jq \
	openssh-client \
	openssl \
	python3 \
	sshpass \
	rsync \
	libxml2 \
	libxslt-dev \
	--repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
	&& ln -sf /usr/bin/python3 /usr/bin/python \
	&& ln -sf ansible /usr/bin/ansible-config \
	&& ln -sf ansible /usr/bin/ansible-console \
	&& ln -sf ansible /usr/bin/ansible-doc \
	&& ln -sf ansible /usr/bin/ansible-inventory \
	&& ln -sf ansible /usr/bin/ansible-pull \
	&& ln -sf ansible /usr/bin/ansible-test \
	&& ln -sf ansible /usr/bin/ansible-vault \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

RUN mkdir -p /etc/ansible \
	&& echo 'localhost'  > /etc/ansible/hosts

USER ${USER}

ENV ANSIBLE_FORCE_COLOR=True

CMD [ "/usr/bin/ansible-playbook", "--version" ]
