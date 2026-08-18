# Taminaru Codespaces devcontainer
#
# Based on the official devcontainers ubuntu template:
#   https://github.com/devcontainers/templates/tree/main/src/ubuntu
# Base image: mcr.microsoft.com/devcontainers/base:ubuntu (resolute / Ubuntu
# 26.04). Unlike a bare `ubuntu:26.04` this ships ca-certificates (so curl can
# reach mise.run), plus git, curl, sudo, common-utils and the `vscode` user.
#
# Everything from mise.toml/mise.lock (incl. pwsh) is provisioned by
# scripts/bootstrap.sh, which is executed HERE so the whole toolchain and the
# pwsh default shell are baked into the image (no wait at container start).
ARG VARIANT="ubuntu"
FROM mcr.microsoft.com/devcontainers/base:${VARIANT}

# ICU is required by PowerShell/.NET globalization. mise installs pwsh from a
# tarball (no apt deps), so the system must provide libicu.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends libicu-dev \
    && rm -rf /var/lib/apt/lists/*

RUN chown -R taminaru:taminaru /workspaces/Taminaru

USER taminaru

# Make pwsh the default shell (needs to be in /etc/shells first).
USER root
RUN echo '/home/taminaru/.local/bin/pwsh' >> /etc/shells \
    && chsh -s /home/taminaru/.local/bin/pwsh taminaru
USER taminaru
