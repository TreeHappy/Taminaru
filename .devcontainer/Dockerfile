# Build stage - Nix for dependency resolution
FROM nixos/nix AS builder

# Install all tools in single Nix profile
RUN nix-env -iA \
    nixpkgs.zsh \
    nixpkgs.neovim \
    nixpkgs.fzf \
    nixpkgs.ripgrep \
    nixpkgs.eza \
    nixpkgs.direnv \
    nixpkgs.yazi \
    nixpkgs.git \
    nixpkgs.starship \
    nixpkgs.gum \
    nixpkgs.youtube-tui \
    nixpkgs.wiki-tui \
    nixpkgs.tailspin \
    --arg config '{ allowUnfree = true; }'

# Create closure of runtime dependencies only
RUN nix-collect-garbage -d

# Final stage - minimal runtime
FROM scratch

# Copy Nix store and profile
COPY --from=builder /nix /nix
COPY --from=builder /etc/profiles/per-user/root /etc/profiles

# Base environment
ENV PATH="/etc/profiles/bin:/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin" \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    USER=devuser \
    HOME=/home/devuser

# Create minimal filesystem structure
RUN <<EOF
#!/bin/sh
mkdir -p /home/devuser /etc/ssl/certs
EOF

# Copy certificates
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Create user (no glibc useradd - static busybox version)
RUN <<EOF
#!/bin/sh
echo 'devuser:x:1000:1000::/home/devuser:/bin/zsh' >> /etc/passwd
echo 'devuser:x:1000:' >> /etc/group
mkdir -p /home/devuser
chown 1000:1000 /home/devuser
EOF

# Configure zsh
USER devuser
WORKDIR /home/devuser
RUN <<EOF
#!/bin/sh
echo 'eval "\$(starship init zsh)"' > .zshrc
mkdir -p .config
echo '[character]' > .config/starship.toml
echo 'success_symbol = "[➜](bold green) "' >> .config/starship.toml
EOF

# Default command
CMD ["zsh", "-l"]