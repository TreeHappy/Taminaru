# Dockerfile
# Stage 2: Create the final lightweight container
FROM ubuntu:rolling

# Create the user first
RUN useradd -m -s /bin/zsh taminaru && \
    apt-get update && apt-get install -y --no-install-recommends \
    fzf \
    bat \
    zsh \
    curl \
    wget \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Set up workspace ownership
RUN mkdir -p /workspace && chown taminaru:taminaru /workspace

# Switch to the user
USER taminaru
WORKDIR /workspace

# Copy the built tools from the builder stage
# COPY --from=builder --chown=taminaru:taminaru /workspace/tool/tool /usr/local/bin/tool

# Set the default shell to zsh
CMD ["zsh"]