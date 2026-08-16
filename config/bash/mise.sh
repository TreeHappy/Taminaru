# mise activation (managed by scripts/bootstrap.sh)
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate bash)"
elif [ -x "$HOME/.local/bin/mise" ]; then
    export PATH="$HOME/.local/bin:$PATH"
    eval "$("$HOME/.local/bin/mise" activate bash)"
fi
