FROM archlinux:base

# Install core packages
RUN pacman -Sy --noconfirm --needed \
    zsh \
    neovim \
    fzf \
    ripgrep \
    eza \
    direnv \
    yazi \
    git \
    curl \
    unzip \
    rust \
    cargo \
    openssl \
    && pacman -Scc --noconfirm

# Install AUR packages (gum)
RUN pacman -Sy --noconfirm --needed base-devel git && \
    git clone https://aur.archlinux.org/gum-bin.git && \
    cd gum-bin && \
    makepkg -si --noconfirm --skippgpcheck && \
    cd .. && \
    rm -rf gum-bin && \
    pacman -Rns --noconfirm git base-devel

# Install Rust tools
RUN cargo install --locked \
    youtube-tui \
    wiki-tui \
    tailspin \
    --root /usr/local

# Install Starship
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir /usr/local/bin

# Create user
RUN useradd -m -s /usr/bin/zsh devuser && \
    echo "devuser ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/devuser

# Configure shell
USER devuser
WORKDIR /home/devuser
RUN mkdir -p ~/.config && \
    echo 'eval "$(starship init zsh)"\n\
    export PATH="$HOME/.pixi/bin:$PATH"\n\
    autoload -Uz compinit && compinit\n\
    zstyle ":completion:*" menu select' > ~/.zshrc && \
    echo "[character]\nsuccess_symbol = '[➜](bold green) '" > ~/.config/starship.toml

# Cleanup
USER root
RUN rm -rf /var/cache/* /tmp/* /root/.cargo
USER devuser

# Start zsh
CMD ["zsh", "-l"]