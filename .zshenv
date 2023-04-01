export JULIA_NUM_THREADS=`cat /proc/cpuinfo | grep "processor" | wc -l`

if [[ -e $HOME/.pyenv ]]; then
  export PYENV_ROOT=$HOME/.pyenv
fi

# setup command search path
# 以下で、重複しないしようするためのフラグを設定する
typeset -U path

typeset -T LD_LIBRARY_PATH ld_library_path
typeset -U ld_library_path

# (N-/)をつければ、すでにpathに存在するときは追加しないよう設定する
path=(
  $HOME/.juliaup/bin(N-/)
  $(pyenv root)/shims(N-/)
  $PYENV_ROOT/bin(N-/)
  $HOME/.local/bin(N-/)
  $HOME/bin(N-/)
  /usr/bin(N-/)
  $path
)

ld_library_path=(
  /usr/lib/julia(N-/)
  $ld_library_path
)

# beep off
setopt no_beep

alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'
alias ll='ls -lah'

[[ -s "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

if [[ -n $DESKTOP_SESSION ]]; then
    eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets)
    export SSH_AUTH_SOCK
fi
