# Stage 1: Build environment
FROM ubuntu:latest AS builder

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Define versions as variables
ARG GO_VERSION=1.20.5
ARG RUST_VERSION=1.70.0  # Update this to the desired Rust version
ARG ZIG_VERSION=0.14.0    # Zig version to install

# Update package lists and install necessary tools
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    wget \
    lsb-release \
    software-properties-common \
    jq \
    zsh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a user and set up home directory
RUN useradd -m taminaru

# Install Go
RUN wget https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

# Set Go environment variables
ENV PATH=$PATH:/usr/local/go/bin

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    rm -rf ~/.cargo/.git && \
    rm -rf ~/.rustup/.git

# Add Cargo to PATH
ENV PATH="$HOME/.cargo/bin:$PATH"

# Install Zig from the specified link
RUN wget https://ziglang.org/builds/zig-linux-x86_64-0.14.0-dev.3011+e4c049e41.tar.xz && \
    tar -xvf zig-linux-x86_64-0.14.0-dev.3011+e4c049e41.tar.xz && \
    mv zig-linux-x86_64-0.14.0-dev.3011+e4c049e41/zig /usr/local/bin/ && \
    rm -rf zig-linux-x86_64-0.14.0-dev.3011+e4c049e41.tar.xz zig-linux-x86_64-0.14.0-dev.3011+e4c049e41

# Install Starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# Switch to the new user
USER taminaru

# Set the working directory
WORKDIR /home/taminaru

# Create .zshrc for the user
RUN echo 'eval "$(starship init zsh)"' >> .zshrc && \
    echo 'export STARSHIP_CONFIG="$HOME/.config/starship.toml"' >> .zshrc && \
    echo 'export EDITOR="vim"' >> .zshrc && \
    echo 'export TERM="xterm-256color"' >> .zshrc && \
    echo 'alias ll="ls -la"' >> .zshrc && \
    echo 'alias gs="git status"' >> .zshrc && \
    echo 'alias gp="git pull"' >> .zshrc && \
    echo 'alias gc="git commit"' >> .zshrc && \
    echo 'export PROMPT="%F{green}%n@%m%f %F{blue}%~%f %# "' >> .zshrc

# Create the Starship configuration directory and file
RUN mkdir -p ~/.config && \
    echo '[character]' > ~/.config/starship.toml && \
    echo 'success_symbol = "[➜](bold green)"' >> ~/.config/starship.toml && \
    echo 'error_symbol = "[✗](bold red)"' >> ~/.config/starship.toml && \
    echo '[directory]' >> ~/.config/starship.toml && \
    echo 'style = "cyan"' >> ~/.config/starship.toml && \
    echo '[git_branch]' >> ~/.config/starship.toml && \
    echo 'symbol = "🌿 "' >> ~/.config/starship.toml && \
    echo 'style = "bold yellow"' >> ~/.config/starship.toml && \
    echo '[time]' >> ~/.config/starship.toml && \
    echo 'format = "%H:%M:%S"' >> ~/.config/starship.toml && \
    echo 'style = "bold blue"' >> ~/.config/starship.toml

# Set the default shell to Zsh
RUN usermod -s $(which zsh) taminaru

# Set the entrypoint to Zsh
ENTRYPOINT ["/usr/bin/zsh"]
