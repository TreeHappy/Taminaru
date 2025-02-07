# Stage 1: Build environment
FROM ubuntu:devel AS builder

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/go/bin:$HOME/.cargo/bin:/usr/local/bin:$PATH"

# Define versions
ARG GO_VERSION=1.20.5
ARG RUST_VERSION=1.70.0
ARG ZIG_VERSION=0.14.0
ARG NEOVIM_VERSION=nightly

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential curl git wget lsb-release \
    software-properties-common jq zsh sudo unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Go
RUN wget https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && rm go${GO_VERSION}.linux-amd64.tar.gz

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && rustup default ${RUST_VERSION} \
    && cargo --version

# Install Zig
RUN wget https://ziglang.org/builds/zig-linux-x86_64-${ZIG_VERSION}-dev.3011+e4c049e41.tar.xz \
    && tar -xf zig-linux-x86_64-${ZIG_VERSION}-dev.3011+e4c049e41.tar.xz \
    && mv zig-linux-x86_64-${ZIG_VERSION}-dev.3011+e4c049e41/zig /usr/local/bin/ \
    && rm -rf zig-*

# Install Neovim
RUN curl -LO https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux-x86_64.tar.gz \
    && tar -C /opt -xzf nvim-linux-x86_64.tar.gz \
    && ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim \
    && rm nvim-linux-x86_64.tar.gz

# Install Moon
RUN curl -fsSL https://moonrepo.dev/install/moon.sh | bash -s -- --force \
    && mv /root/.moon/bin/moon /usr/local/bin/moon \
    && mv /root/.moon/bin/moonc /usr/local/bin/moonc \
    && rm -rf /root/.moon

# Install Pandoc
RUN PANDOC_URL=$(curl -s https://api.github.com/repos/jgm/pandoc/releases/latest | grep "browser_download_url.*linux-amd64.tar.gz" | cut -d '"' -f 4) \
    && wget $PANDOC_URL \
    && tar -xzf pandoc-*-linux-amd64.tar.gz \
    && mv pandoc-*/bin/pandoc /usr/local/bin/ \
    && rm -rf pandoc-*

# Install Starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

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
