FROM alpine:3.11.3 as builder

ARG ANSIBLE_VERSION=2.9.4

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
	rsync 

RUN apk --update --no-cache add --virtual \
	.build-deps \
	sshpass \
	python3-dev \
	libffi-dev \
	openssl-dev \
	build-base 

COPY .requirements.txt /.requirements.txt 

RUN set -eux \
	&& pip3 install --no-cache-dir ansible==${ANSIBLE_VERSION} \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

RUN set -eux \
	&& pip3 install --upgrade -r /.requirements.txt \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

FROM alpine:3.11.3 as production

ENV \
	USER=ansible \
	GROUP=ansible \
	UID=1000 \
	GID=1000

ARG ANSIBLE_VERSION=2.9.4

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

COPY --from=builder /usr/lib/python3.8/site-packages/ /usr/lib/python3.8/site-packages/
COPY --from=builder /usr/bin/ansible /usr/bin/ansible
COPY --from=builder /usr/bin/ansible-connection /usr/bin/ansible-connection

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
	python3 \
	&& ln -sf /usr/bin/python3 /usr/bin/python \
	&& ln -sf ansible /usr/bin/ansible-config \
	&& ln -sf ansible /usr/bin/ansible-console \
	&& ln -sf ansible /usr/bin/ansible-doc \
	&& ln -sf ansible /usr/bin/ansible-galaxy \
	&& ln -sf ansible /usr/bin/ansible-inventory \
	&& ln -sf ansible /usr/bin/ansible-playbook \
	&& ln -sf ansible /usr/bin/ansible-pull \
	&& ln -sf ansible /usr/bin/ansible-test \
	&& ln -sf ansible /usr/bin/ansible-vault \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

RUN mkdir -p /etc/ansible \
	&& echo 'localhost'  > /etc/ansible/hosts

USER ${USER}

CMD [ "/usr/bin/ansible-playbook", "--version" ]
