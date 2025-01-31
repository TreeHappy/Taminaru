FROM archlinux:base

# Minimal package installation with direct dependencies
RUN pacman -Sy --noconfirm --needed \
    zsh \
    starship \
    neovim \
    fzf \
    ripgrep \
    eza \
    direnv \
    yazi \
    git \
    curl \
    less \
    man-db \
    sudo \
    && pacman -Scc --noconfirm  # Clean package cache

# Remove unnecessary system components
RUN rm -rf \
    /usr/share/fonts/OTF \
    /usr/share/fonts/TTF \
    /usr/share/i18n \
    /usr/share/zoneinfo/leap-seconds.list \
    /usr/share/zoneinfo/right \
    /var/cache/pacman/pkg/*

# Configure zsh as default shell
RUN chsh -s /usr/bin/zsh && \
    echo "export STARSHIP_CONFIG=~/.config/starship.toml" >> /etc/zsh/zshenv

# Create minimal user environment
RUN useradd -m -s /usr/bin/zsh devuser && \
    echo "devuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/devuser

USER devuser
WORKDIR /home/devuser

# Minimal starship config
RUN mkdir -p ~/.config && \
    echo "[character]\nsuccess_symbol = '[➜](bold green) '" > ~/.config/starship.toml

ENV SHELL=/usr/bin/zsh
