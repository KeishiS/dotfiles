# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Juliaup
if [ ! -s "$HOME/.juliaup" ]; then
    curl -fsSL https://install.julialang.org | sh -s -- --yes
fi

# pyenv
if [ ! -s "$HOME/.pyenv" ]; then
    curl https://pyenv.run | bash
fi

# rye
if [ ! -s "$HOME/.rye" ]; then
    curl -sSf https://rye-up.com/get | bash
else
    source "$HOME/.rye/env"
fi

eval "$(starship init zsh)"

# GnuPG
export GNUPGHOME=$HOME/.gnupg
