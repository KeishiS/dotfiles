# setup command search path
typeset -U path
typeset -T LD_LIBRARY_PATH ld_library_path
typeset -U ld_library_path

# (N-/)をつければ、すでにpathに存在するときは追加しないよう設定する
path=(
  $HOME/.juliaup/bin(N-/)
  $HOME/.cargo/bin(N-/)
  $HOME/.local/bin(N-/)
  $HOME/.pyenv/bin(N-/)
  $HOME/.nimble/bin(N-/)
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
