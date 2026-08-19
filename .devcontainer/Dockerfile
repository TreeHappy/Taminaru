# Taminaru Codespaces devcontainer
#
# Lean base: bare `ubuntu:26.04` (~39MB) instead of the devcontainers ubuntu
# image. Everything (tools, dotfiles, treesitter C compiler via nix `zig`,
# pwsh default shell) is provisioned at container start by
# scripts/bootstrap.sh via home-manager, so the image only needs the bootstrap
# prerequisites (curl, git, sudo) plus ca-certificates for TLS.
ARG VARIANT="26.04"
FROM ubuntu:${VARIANT}

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends ca-certificates curl git sudo \
    && rm -rf /var/lib/apt/lists/*

# Non-root user (matches devcontainer.json "remoteUser") with passwordless sudo.
RUN useradd -m -s /bin/bash taminaru \
    && echo 'taminaru ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/taminaru \
    && chmod 0440 /etc/sudoers.d/taminaru

RUN chown -R taminaru:taminaru /home/taminaru

USER taminaru
WORKDIR /home/taminaru
