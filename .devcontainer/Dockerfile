# syntax=docker/dockerfile:1

FROM alpine:latest

# Install system packages
RUN apk add --no-cache \
    neovim \
    fzf \
    ripgrep \
    direnv \
    git \
    bash \
    curl \
    unzip

# Install eza from GitHub release
RUN curl -LOf https://github.com/eza-community/eza/releases/latest/download/eza-x86_64-unknown-linux-musl.zip && \
    unzip eza-x86_64-unknown-linux-musl.zip -d /tmp/eza && \
    mv /tmp/eza/bin/eza /usr/local/bin/ && \
    rm -rf /tmp/eza eza-x86_64-unknown-linux-musl.zip

# Install yazi from GitHub release
RUN curl -LOf https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-musl.tar.gz && \
    tar -xzf yazi-x86_64-unknown-linux-musl.tar.gz -C /usr/local/bin yazi && \
    rm yazi-x86_64-unknown-linux-musl.tar.gz

# Install starship
RUN curl -fsS https://starship.rs/install.sh | sh -s -- --yes --bin-dir /usr/local/bin

# Create non-root user
RUN adduser -D devuser && \
    mkdir -p /home/devuser/.config && \
    chown -R devuser:devuser /home/devuser

USER devuser
WORKDIR /home/devuser
ENV SHELL=/bin/bash