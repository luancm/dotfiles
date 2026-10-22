ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

# A new machine: one sudo user, git, and no apt package lists.
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends sudo git ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -m -s /bin/bash dev \
 && echo 'dev ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/dev

USER dev
WORKDIR /home/dev
COPY --chown=dev:dev . /home/dev/.dotfiles

CMD ["bash", "/home/dev/.dotfiles/test/install-smoke-run.sh"]
