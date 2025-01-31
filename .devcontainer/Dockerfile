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
    # Add Starship dependencies
    fonts-powerline \
    && rm -rf /var/lib/apt/lists/*

# Install Starship (as root)
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# Configure Starship for the user
RUN echo '\n# Starship prompt\neval "$(starship init zsh)"' >> /home/taminaru/.zshrc && \
    echo '\n# Enable cool prompt features\nstarship preset pastel-powerline > ~/.config/starship.toml' >> /home/taminaru/.zshrc

# Set up workspace ownership
RUN mkdir -p /workspace && chown taminaru:taminaru /workspace

# Switch to the user
USER taminaru
WORKDIR /workspace

# Set default config for Starship
RUN mkdir -p /home/taminaru/.config && \
    starship preset pastel-powerline > /home/taminaru/.config/starship.toml

# Copy the built tools from the builder stage
# COPY --from=builder --chown=taminaru:taminaru /workspace/tool/tool /usr/local/bin/tool

# Set the default shell to zsh
CMD ["zsh"]
