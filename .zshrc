# Init zsh plugin manager
if [[ ! -d ~/.config/sheldon ]]; then
    sheldon init --shell zsh
fi
eval "$(sheldon source)"
