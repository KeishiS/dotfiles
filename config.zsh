#------------------------------------------------
export GNUPGHOME=$HOME/.gnupg
export JULIA_NUM_THREADS=`cat /proc/cpuinfo | grep "processor" | wc -l`

#------------------------------------------------

# prompt by starship
eval "$(starship init zsh)"

# rye
if [[ ! -d $HOME/.rye ]]; then
    curl -sSf https://rye-up.com/get | bash
else
    source $HOME/.rye/env
fi

# Juliaup
if [[ ! -d $HOME/.juliaup ]]; then
    curl -fsSL https://install.julialang.org | sh -s -- --yes
fi

# cargo
if [[ ! -d $HOME/.cargo ]]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
else
  source $HOME/.cargo/env
fi

#------------------------------------------------

if [[ -n $DESKTOP_SESSION ]]; then
    eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets)
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
fi

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

autoload -Uz compinit && compinit
bindkey "^p" history-beginning-search-backward
bindkey "^n" history-beginning-search-forward
bindkey "^e" end-of-line
bindkey "^a" beginning-of-line
bindkey "^f" forward-char
bindkey "^b" backward-char
