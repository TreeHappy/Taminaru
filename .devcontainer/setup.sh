#!/bin/bash

# Update package lists and install base-devel for building packages
pacman -Syu --noconfirm
pacman -S --noconfirm base-devel

# Install additional TUI programs and utilities
pacman -S --noconfirm \
    htop \
    ranger \
    fzf \
    bat \
    neofetch \
    zsh \
    yazi \
    gopass \
    mailcap \
    task \
    duckdb \
    cmatrix \
    nmap \
    curl \
    wget \
    zellij \
    starship

# Install Go
pacman -S --noconfirm go

# Install Charmbracelet tools: gum and glow
# Install gum
curl -sSL https://github.com/charmbracelet/gum/releases/latest/download/gum_linux_amd64.tar.gz | tar xz -C /usr/local/bin

# Install glow
curl -sSL https://github.com/charmbracelet/glow/releases/latest/download/glow_linux_amd64.tar.gz | tar xz -C /usr/local/bin

# Set Zsh as the default shell for the user
chsh -s /bin/zsh

# Create a Starship configuration file
mkdir -p ~/.config
echo 'eval "$(starship init zsh)"' > ~/.config/starship.toml

# Clean up
pacman -Scc --noconfirm

