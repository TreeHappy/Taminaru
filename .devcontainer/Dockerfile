# Stage 1: Build tools
FROM alpine:latest AS builder

# Install necessary build tools and dependencies, including Go and Rust
RUN apk add --no-cache \
    build-base \
    git \
    bash \
    curl \
    wget \
    jq \
    cmake \
    pkgconfig \
    sqlite-dev \
    libressl-dev \
    go \
    rust

# Set the working directory
WORKDIR /workspace

# Build gum
RUN git clone --depth 1 https://github.com/charmbracelet/gum.git
WORKDIR /workspace/gum
RUN go build -o gum ./cmd/gum

# Build starship
WORKDIR /workspace
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# Build cheat
WORKDIR /workspace
RUN git clone --depth 1 https://github.com/cheat/cheat.git
WORKDIR /workspace/cheat
RUN go build -o cheat ./cmd/cheat

# Build carapace
WORKDIR /workspace
RUN git clone --depth 1 https://github.com/rsteube/carapace.git
WORKDIR
