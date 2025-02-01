# Stage 1: Build environment
FROM ubuntu:latest AS builder

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install necessary tools
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    wget \
    lsb-release \
    software-properties-common \
    jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Go
RUN wget https://golang.org/dl/go1.20.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.20.5.linux-amd64.tar.gz && \
    rm go1.20.5.linux-amd64.tar.gz

# Set Go environment variables
ENV PATH=$PATH:/usr/local/go/bin

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    rm -rf ~/.cargo/.git && \
    rm -rf ~/.rustup/.git

# Install Zig
RUN wget https://ziglang.org/download/index.json -O zig.json && \
    ZIG_VERSION=$(jq -r '.["0.11.0"]."x86_64-linux"."tarball"' zig.json)
