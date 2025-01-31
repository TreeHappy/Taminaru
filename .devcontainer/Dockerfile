FROM archlinux:base

# Install core packages
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

# Install pre-built binaries
RUN curl -fsSL https://pixi.sh/install.sh | bash -s -- -y && \
    curl -L https://github.com/bensadeh/tailspin/releases/latest/download/tailspin-x86_64-unknown-linux-musl.tar.gz | tar xz -C /usr/local/bin && \
    curl -LO https://github.com/siriusmart/youtube-tui/releases/latest/download/yt-tui-x86_64-unknown-linux-gnu.zip && \
    unzip yt-tui-x86_64-unknown-linux-gnu.zip -d /usr/local/bin && \
    curl -LO https://github.com/Builditluc/wiki-tui/releases/latest/download/wiki-tui-x86_64-unknown-linux-gnu.tar.gz && \
    tar -xzf wiki-tui-x86_64-unknown-linux-gnu.tar.gz -C /usr/local/bin

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

ENV SHELL=/usr/bin/zsh \
    PATH="/home/devuser/.pixi/bin:$PATH"

# Cleanup
USER root
RUN rm -rf /var/cache/* /tmp/* /root/.cargo
USER devuser