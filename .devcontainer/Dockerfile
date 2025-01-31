# Stage 1: Build tools
FROM golang:1.20-alpine AS builder

# Install Rust and other necessary build tools
RUN apk add --no-cache \
    rust \
    cargo \
    build-base \
    git \
    bash \
    curl \
    wget \
    jq

# Set the working directory
WORKDIR /workspace

# Build zellij
RUN git clone --depth 1 https://github.com/zellij-org/zellij.git
WORKDIR /workspace/zellij
RUN cargo build --release

# Build gum
WORKDIR /workspace
RUN git clone --depth 1 https://github.com/charmbracelet/gum.git
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
WORKDIR /workspace/carapace
RUN go build -o carapace ./cmd/carapace

# Stage 2: Create the final lightweight container
FROM alpine:latest

# Install additional tools
RUN apk add --no-cache \
    fzf \
    bat \
    zsh \
    yazi \
    gopass \
    task \
    duckdb \
    curl \
    wget \
    jq \
    zellij \
    starship \
    cheat \
    neovim \
    taskwarrior \
    irssi

# Copy the built tools from the builder stage
COPY --from=builder /workspace/zellij/target/release/zellij /usr/local/bin/zellij
COPY --from=builder /workspace/gum/gum /usr/local/bin/gum
COPY --from=builder /root/.cargo/bin/starship /usr/local/bin/starship
COPY --from=builder /workspace/cheat/cheat /usr/local/bin/cheat
COPY --from=builder /workspace/carapace/carapace /usr/local/bin/carapace

# Set the entrypoint (optional)
ENTRYPOINT ["/usr/local/bin/zellij"]

# Optionally, you can expose ports or define other configurations
# EXPOSE 8080
