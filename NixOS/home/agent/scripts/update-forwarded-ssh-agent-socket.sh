#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "使用法: update-forwarded-ssh-agent-socket <ソケットディレクトリ> <固定ソケット>" >&2
  exit 2
fi

agent_directory=$1
stable_socket=$2

mkdir -p "$agent_directory"
chmod 700 "$agent_directory"

exec 9>"$agent_directory/.current.lock"
flock 9

newest_socket=
newest_mtime=0

for candidate in "$agent_directory"/s.*.sshd.*; do
  if [ ! -S "$candidate" ]; then
    continue
  fi

  candidate_mtime=$(stat -c %Y "$candidate" 2>/dev/null) || continue
  if [ "$candidate_mtime" -ge "$newest_mtime" ]; then
    newest_socket=$candidate
    newest_mtime=$candidate_mtime
  fi
done

current_socket=$(readlink "$stable_socket" 2>/dev/null || true)

if [ -z "$newest_socket" ]; then
  if [ -L "$stable_socket" ]; then
    rm "$stable_socket"
  fi
elif [ "$current_socket" != "$newest_socket" ]; then
  ln -sfn "$newest_socket" "$stable_socket"
fi
