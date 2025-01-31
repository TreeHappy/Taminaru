FROM archlinux:base-devel

# Install all tools from official repos
RUN pacman -Sy --noconfirm --needed \
    neovim \
    fzf \
    ripgrep \
    eza \
    direnv \
    yazi \
    git \
    starship \
    bash \
    curl

# Create non-root user
RUN useradd -m devuser && \
    chown -R devuser:devuser /home/devuser

USER devuser
WORKDIR /home/devuser
ENV SHELL=/bin/bash