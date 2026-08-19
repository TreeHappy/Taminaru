# Taminaru Codespaces devcontainer
#
# Lean base: bare `ubuntu:26.04` (~39MB) instead of the devcontainers ubuntu
# image. Everything (tools, dotfiles, treesitter C compiler via nix `zig`,
# pwsh default shell) is provisioned at container start by
# scripts/bootstrap.sh via home-manager, so the image only needs the bootstrap
# prerequisites (curl, git, sudo) plus ca-certificates for TLS.
ARG VARIANT="26.04"
FROM ubuntu:${VARIANT}

ARG TAMINARU_USER="taminaru"
ARG TAMINARU_UID=1000

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends ca-certificates curl git sudo \
    && rm -rf /var/lib/apt/lists/*

# Non-root user (matches devcontainer.json "remoteUser") with passwordless
# sudo, provisioned by the same script the bootstrap uses.
COPY scripts/provision-user.sh /tmp/provision-user.sh
RUN TAMINARU_USER="$TAMINARU_USER" TAMINARU_UID="$TAMINARU_UID" bash /tmp/provision-user.sh \
    && rm -f /tmp/provision-user.sh

USER ${TAMINARU_USER}
WORKDIR /home/${TAMINARU_USER}
