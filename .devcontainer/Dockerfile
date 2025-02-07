# Stage 1: Build environment
FROM ubuntu:devel AS builder

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/usr/local/go/bin:/root/.cargo/bin:/usr/local/bin:$PATH"

ARG GO_VERSION=1.20.5
ARG RUST_VERSION=1.70.0
ARG ZIG_VERSION=0.14.0
ARG NEOVIM_VERSION=nightly

# Install system dependencies quietly
RUN apt-get update -qq && apt-get install -yqq --no-install-recommends \
    build-essential curl git wget lsb-release \
    software-properties-common jq zsh sudo unzip \
    && apt-get clean -qq \
    && rm -rf /var/lib/apt/lists/*

# Install Go silently
RUN wget -q https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && rm -f go*.tar.gz

# Install Rust with quiet output
RUN curl -sSf --proto '=https' --tlsv1.2 https://sh.rustup.rs | sh -s -- -y \
    && . "$HOME/.cargo/env" \
    && rustup default ${RUST_VERSION} -q \
    && rustup --version \
    && cargo --version

# Install Zig quietly
RUN wget -q https://ziglang.org/builds/zig-linux-x86_64-${ZIG_VERSION}-dev.3011+e4c049e41.tar.xz \
    && tar -xf zig-*.tar.xz \
    && mv zig-*/zig /usr/local/bin/ \
    && rm -rf zig-*

# Install Neovim silently
RUN curl -sSL -o nvim.tar.gz https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux-x86_64.tar.gz \
    && tar -C /opt -xzf nvim.tar.gz \
    && ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim \
    && rm -f nvim.tar.gz

# Install Moon via npm (quiet)
RUN npm install -g @moonrepo/cli@latest --silent

# Install Pandoc quietly
RUN PANDOC_URL=$(curl -s https://api.github.com/repos/jgm/pandoc/releases/latest | grep "browser_download_url.*linux-amd64.tar.gz" | cut -d '"' -f 4) \
    && wget -q $PANDOC_URL \
    && tar -xzf pandoc-*.tar.gz \
    && mv pandoc-*/bin/pandoc /usr/local/bin/ \
    && rm -rf pandoc-*

# Install Starship silently
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes > /dev/null

# Configure user
RUN useradd -m taminaru \
    && usermod -aG sudo taminaru \
    && echo 'taminaru ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/taminaru \
    && chmod 0440 /etc/sudoers.d/taminaru \
    && usermod -s /usr/bin/zsh taminaru

USER taminaru
WORKDIR /home/taminaru

# Configure shell
RUN echo 'eval "$(starship init zsh)"' >> ~/.zshrc \
    && echo 'export STARSHIP_CONFIG="$HOME/.config/starship.toml"' >> ~/.zshrc \
    && echo 'export EDITOR="nvim"' >> ~/.zshrc \
    && mkdir -p ~/.config \
    && printf '[character]\nsuccess_symbol = "[➜](bold green)"\nerror_symbol = "[✗](bold red)"\n[directory]\nstyle = "cyan"\n[git_branch]\nsymbol = "🌿 "\nstyle = "bold yellow"\n[time]\nformat = "%%H:%%M:%%S"\nstyle = "bold blue"\n' > ~/.config/starship.toml

ENTRYPOINT ["/usr/bin/zsh"]
