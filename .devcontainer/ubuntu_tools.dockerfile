# Stage 1: Build environment
FROM ubuntu:plucky AS builder

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Define versions as variables
ARG NEOVIM_VERSION=nightly # Change this to a specific version if needed

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
    sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Neovim
RUN curl -LO https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux-x86_64.tar.gz && \
if [ $? -ne 0 ]; then echo "Failed to download Neovim"; exit 1; fi && \
rm -rf /opt/nvim && \
tar -C /opt -xzf nvim-linux-x86_64.tar.gz && \
rm nvim-linux-x86_64.tar.gz

# Set Neovim in PATH
ENV PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# Install Starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# Create a user and set up home directory
# TODO: user needs a password
RUN useradd -m taminaru && \
    usermod -aG sudo taminaru

# Set the default shell to Zsh
RUN usermod -s $(which zsh) taminaru

# Switch to the new user
USER taminaru

# Set the working directory
WORKDIR /home/taminaru

# Create .zshrc for the user
RUN echo 'eval "$(starship init zsh)"' >> .zshrc && \
    echo 'export STARSHIP_CONFIG="$HOME/.config/starship.toml"' >> .zshrc && \
    echo 'export EDITOR="nvim"' >> .zshrc && \
    echo 'export TERM="xterm-256color"' >> .zshrc && \
    echo 'alias ll="ls -la"' >> .zshrc && \
    echo 'alias gs="git status"' >> .zshrc && \
    echo 'alias gp="git pull"' >> .zshrc && \
    echo 'alias gc="git commit"' >> .zshrc

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

# Set the entrypoint to Zsh
ENTRYPOINT ["/usr/bin/zsh"]

