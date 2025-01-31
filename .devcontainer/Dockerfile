# syntax=docker/dockerfile:1

# Build stage for Rust tools
FROM alpine:latest AS builder

RUN apk add --no-cache \
    rust \
    cargo \
    musl-dev \
    openssl-dev \
    git

# Build eza
RUN git clone https://github.com/eza-community/eza && \
    cd eza && \
    cargo build --locked --release && \
    mv target/release/eza /usr/local/bin

# Build yazi
RUN git clone https://github.com/sxyazi/yazi && \
    cd yazi && \
    cargo build --locked --release && \
    mv target/release/yazi /usr/local/bin

# Final stage
FROM alpine:latest

RUN apk add --no-cache \
    neovim \
    fzf \
    ripgrep \
    direnv \
    git \
    bash \
    curl

COPY --from=builder /usr/local/bin/eza /usr/local/bin/
COPY --from=builder /usr/local/bin/yazi /usr/local/bin/

# Install starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir /usr/local/bin

# Create non-root user
RUN adduser -D devuser && \
    mkdir -p /home/devuser/.config && \
    chown -R devuser:devuser /home/devuser

USER devuser
WORKDIR /home/devuser
ENV SHELL=/bin/bash