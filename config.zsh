#------------------------------------------------
export GNUPGHOME=$HOME/.gnupg
export JULIA_NUM_THREADS=`cat /proc/cpuinfo | grep "processor" | wc -l`
export JULIA_PKG_USE_CLI_GIT=true
export PYENV_ROOT=$HOME/.pyenv
export ELECTRON_OZONE_PLATFORM_HINT=auto
#------------------------------------------------

# prompt by starship
eval "$(starship init zsh)"

# pyenv
if [[ ! -d $HOME/.pyenv ]]; then
  curl https://pyenv.run | bash
else
  eval "$(pyenv init -)"
fi

# Poetry
if [[ ! -f $HOME/.local/bin/poetry ]]; then
  curl -sSL https://install.python-poetry.org | python3 -
fi

# Juliaup
if [[ ! -d $HOME/.juliaup ]]; then
    curl -fsSL https://install.julialang.org | sh -s -- --yes
fi

# cargo
if [[ ! -d $HOME/.cargo ]]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
source $HOME/.cargo/env

# # uv
# if [[ `command -v uv` == "" ]]; then
#   curl -LsSf https://astral.sh/uv/install.sh | sh
# fi


# # rye
# if [[ ! -d $HOME/.rye ]]; then
#   curl -sSf https://rye-up.com/get | bash
# fi
# source $HOME/.rye/env

# nvm
if [[ -d /usr/share/nvm/ ]]; then
  source /usr/share/nvm/init-nvm.sh
fi

#------------------------------------------------

if [[ -n $DESKTOP_SESSION ]]; then
    dbus-update-activation-environment --systemd DISPLAY
    eval $(/usr/bin/gnome-keyring-daemon -r -d --components=pkcs11,secrets,ssh)
    export GPG_TTY=$(tty)
    echo UPDATESTARTUPTTY | gpg-connect-agent
fi
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

#------------------------------------------------

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_all_dups # 重複するコマンドは古い方を削除
setopt hist_ignore_dups     # 直前と同じコマンドはファイルに残さない
setopt share_history        # コマンド履歴ファイルを共有
setopt append_history       # 毎回.zsh_historyを作るのではなく追記
setopt inc_append_history

#------------------------------------------------

fpath+=~/.zfunc
autoload -Uz compinit && compinit
bindkey "^p" history-beginning-search-backward
bindkey "^n" history-beginning-search-forward
bindkey "^e" end-of-line
bindkey "^a" beginning-of-line
bindkey "^f" forward-char
bindkey "^b" backward-char
