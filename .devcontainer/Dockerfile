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

# Set Rust environment variables
ENV PATH=$PATH:/root/.cargo/bin

# Install Zig
RUN wget https://ziglang.org/download/index.json -O zig.json && \
    ZIG_VERSION=$(jq -r '.["0.11.0"]."x86_64-linux"."tarball"' zig.json) && \
    wget $ZIG_VERSION && \
    tar -xvf zig-linux-x86_64-*.tar.xz && \
    mv zig-linux-x86_64-* /usr/local/zig && \
    rm zig-linux-x86_64-*.tar.xz zig.json

# Stage 2: Final image
FROM ubuntu:latest

# Install Zsh and other dependencies
RUN apt-get update && apt-get install -y zsh curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Starship with --yes option
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# Create user taminaru
RUN useradd -m -s /bin/zsh taminaru

# Copy Go, Rust, and Zig from the builder stage
COPY --from=builder /usr/local/go /usr/local/go
COPY --from=builder /root/.cargo /root/.cargo
COPY --from=builder /usr/local/zig /usr/local/zig

# Set environment variables for the final image
ENV PATH=$PATH:/usr/local/go/bin:/root/.cargo/bin:/usr/local/zig:/home/taminaru/.cargo/bin

# Configure Starship in .zshrc for the new user
RUN echo 'eval "$(starship init zsh)"' >> /home/taminaru/.zshrc

# Set the working directory
WORKDIR /app

# Switch to the new user
USER taminaru

# Start Zsh by default
CMD ["zsh"]
