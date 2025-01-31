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

# # Build gum
# RUN git clone --depth 1 https://github.com/charmbracelet/gum.git
# WORKDIR /workspace/gum
# RUN go build -o gum ./cmd/gum

# Build starship
WORKDIR /workspace
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# # Build cheat
# WORKDIR /workspace
# RUN git clone --depth 1 https://github.com/cheat/cheat.git
# WORKDIR /workspace/cheat
# RUN go build -o cheat ./cmd/cheat

# # Build carapace
# WORKDIR /workspace
# RUN git clone --depth 1 https://github.com/rsteube/carapace.git
# WORKDIR /workspace/carapace
# RUN go build -o carapace ./cmd/carapace

# # Build taskwarrior
# WORKDIR /workspace
# RUN git clone --depth 1 https://git.taskwarrior.org/taskwarrior/taskwarrior.git
# WORKDIR /workspace/taskwarrior
# RUN cmake . && make && make install

# # Build duckdb
# WORKDIR /workspace
# RUN git clone --depth 1 https://github.com/duckdb/duckdb.git
# WORKDIR /workspace/duckdb
# RUN mkdir build && cd build && cmake .. && make && make install

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
    starship \
    neovim \
    irssi

# Copy the built tools from the builder stage
# COPY --from=builder /workspace/gum/gum /usr/local/bin/gum
# COPY --from=builder /root/.cargo/bin/starship /usr/local/bin/starship
# COPY --from=builder /workspace/cheat/cheat /usr/local/bin/cheat
# COPY --from=builder /workspace/carapace/carapace /usr/local/bin/carapace
# COPY --from=builder /usr/local/bin/task /usr/local/bin/task
# COPY --from=builder /usr/local/bin/duckdb /usr/local/bin/duckdb

# Set the entrypoint (optional)
ENTRYPOINT ["/usr/local/bin/gum"]

# Optionally, you can expose ports or define other configurations
# EXPOSE 8080
