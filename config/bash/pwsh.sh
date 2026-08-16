# start pwsh from an interactive bash, in $HOME (managed by scripts/bootstrap.sh)
if command -v pwsh >/dev/null 2>&1 && [[ $- == *i* ]]; then
    cd "$HOME"
    exec pwsh
fi
