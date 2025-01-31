# Stage 1: Build tools
FROM ubuntu:rolling AS builder

# Install necessary build tools and dependencies, including Go and Rust
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    wget \
    golang \
    rustc \
    cargo \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /workspace

# Example: Build a command line tool (replace with actual tool)
# RUN git clone --depth 1 https://github.com/example/tool.git
# WORKDIR /workspace/tool
# RUN go build -o tool ./cmd/tool

# Stage 2: Create the final lightweight container
FROM ubuntu:chiseled

# Install additional command line tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    fzf \
    bat \
    zsh \
    curl \
    wget \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Copy the built tools from the builder stage
# COPY --from=builder /workspace/tool/tool /usr/local/bin/tool

# Set the default shell to zsh
CMD ["zsh"]
