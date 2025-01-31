# Stage 1: Build tools
FROM alpine:latest AS builder

# Install necessary build tools and dependencies
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
    libressl-dev

# Install the latest version of Go
RUN curl -sSL https://golang.org/dl/go1.20.5.linux-amd64.tar.gz | tar -C /usr/local -xz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install the latest version of Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

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

# Build taskwarrior
WORKDIR /workspace
RUN git clone --depth 1 https://git.taskwarrior.org/taskwarrior/taskwarrior.git
WORKDIR /workspace/taskwarrior
RUN cmake . && make && make install

# Build duckdb
WORKDIR /workspace
RUN git clone --depth 1 https://github.com/duckdb/duckdb.git
WORKDIR /workspace/duckdb
RUN mkdir build && cd build && cmake .. && make && make install

# Stage 2: Create the final lightweight container
FROM alpine:latest

# Install additional tools
RUN apk add --no-cache \
    fzf \
    bat \
    zsh \
    gopass \
    curl \
    wget \
    jq \
    zellij \
    starship \
    neovim \
    irssi

# Copy the built tools from the builder stage
COPY --from=builder /workspace/zellij/target/release/zellij /usr/local/bin/zellij
COPY --from=builder /workspace/gum/gum /usr/local/bin/gum
COPY --from=builder /root/.cargo/bin/starship /usr/local/bin/starship
COPY --from=builder /workspace/cheat/cheat /usr/local/bin/cheat
COPY --from=builder /workspace/carapace/carapace /usr/local/bin/carapace
COPY --from=builder /usr/local/bin/task /usr/local/bin/task
COPY --from=builder /usr/local/bin/duckdb /usr/local/bin/duckdb

# Set the entrypoint (optional)
ENTRYPOINT ["/usr/local/bin/zellij"]

# Optionally, you can expose ports or define other configurations
# EXPOSE 8080
