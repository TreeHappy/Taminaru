# Taminaru Codespaces devcontainer
#
# Ubuntu 26 (Resolute) - the official Ubuntu "Core"-derived minimal image.
# Every tool (incl. pwsh) is provisioned by mise (see mise.toml / mise.lock)
# instead of being baked in by hand, so the toolchain stays declarative.
#
# The workspace is mounted at runtime, so configs/themes are applied by
# scripts/bootstrap.sh (see devcontainer.json postCreateCommand), not here.
FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

# Only OS-level essentials; the rest comes from mise.
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        git \
        sudo \
    && rm -rf /var/lib/apt/lists/*

# Non-root user (matches devcontainer.json "remoteUser") with passwordless sudo.
RUN useradd -m -s /bin/bash taminaru \
    && echo 'taminaru ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/taminaru \
    && chmod 0440 /etc/sudoers.d/taminaru

USER taminaru
WORKDIR /home/taminaru

# Install mise into the user's home.
RUN curl -fsSL https://mise.run | sh

ENV PATH="/home/taminaru/.local/bin:/home/taminaru/.local/share/mise/shims:$PATH" \
    MISE_DATA_DIR="/home/taminaru/.local/share/mise"

# Bake the entire toolchain into the image so container startup is instant.
# (mise.lock pins exact versions; the workspace's mise.toml is used at runtime.)
COPY --chown=taminaru:taminaru mise.toml mise.lock /tmp/mise/
RUN mkdir -p "$MISE_DATA_DIR" \
    && cd /tmp/mise \
    && mise install \
    && ln -sfn "$(mise where powershell)/pwsh" "$HOME/.local/bin/pwsh" \
    && rm -rf /tmp/mise

# Make pwsh the default shell (needs to be in /etc/shells first).
USER root
RUN echo '/home/taminaru/.local/bin/pwsh' >> /etc/shells \
    && chsh -s /home/taminaru/.local/bin/pwsh taminaru
USER taminaru

CMD ["/home/taminaru/.local/bin/pwsh"]