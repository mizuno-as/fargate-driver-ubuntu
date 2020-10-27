FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------------------
# Install tini
# https://github.com/krallin/tini
# ---------------------------------------------------------------------
ARG TINI_VERSION=v0.19.0
RUN apt update && \
    apt install -y curl && \
    curl -Lo /usr/local/bin/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-amd64 && \
    chmod +x /usr/local/bin/tini

# ---------------------------------------------------------------------
# Install awscli
# ---------------------------------------------------------------------
RUN apt install -y python3-pip && \
    pip3 install awscli

# ---------------------------------------------------------------------
# Install Terraform
# https://learn.hashicorp.com/tutorials/terraform/install-cli
# ---------------------------------------------------------------------
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    apt install -y software-properties-common && \
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    apt update && \
    apt install -y terraform

# --------------------------------------------------------------------------
# Install and configure sshd
# https://docs.docker.com/engine/examples/running_ssh_service
# --------------------------------------------------------------------------
RUN apt install -y openssh-server && \
    mkdir -p /run/sshd

EXPOSE 22

# ----------------------------------------
# Install GitLab CI required dependencies.
# ----------------------------------------
ARG GITLAB_RUNNER_VERSION=v13.5.0
RUN curl -Lo /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/${GITLAB_RUNNER_VERSION}/binaries/gitlab-runner-linux-amd64 && \
    chmod +x /usr/local/bin/gitlab-runner && \
    gitlab-runner --version

RUN apt install -y bash ca-certificates git git-lfs && \
    git lfs install --skip-repo

# -------------------------------------------------------------------------------------
# Execute a startup script.
# https://success.docker.com/article/use-a-script-to-initialize-stateful-container-data
# for reference.
# -------------------------------------------------------------------------------------
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["tini", "--", "/usr/local/bin/docker-entrypoint.sh"]

