if [ -n "${IN_AGENT_BWRAP:-}" ]; then
    exec "$SANDBOX_ZSH" -i
fi

export IN_AGENT_BWRAP=1
host_home=$HOME
project_hash=$(printf '%s' $PROJECT_NAME | sha256sum | cut -c1-16)
default_tmp_home="/tmp/sandbox-${UID:-$(id -u)}-$project_hash"
tmp_home="${SANDBOX_HOME:-$default_tmp_home}"
tmp_home="$(realpath -m "$tmp_home")"

case "$tmp_home" in
/tmp/*) ;;
*)
    echo "SANDBOX_HOME must point under /tmp: $tmp_home" >&2
    exit 1
    ;;
esac

if [ -e "$tmp_home" ] && [ ! -d "$tmp_home" ]; then
    echo "AGENT_SANDBOX_HOME exists but is not a directory: $tmp_home" >&2
    exit 1
fi

current_uid="$(id -u)"
if [ -d "$tmp_home" ]; then
    home_owner_uid="$(stat -c '%u' "$tmp_home")"
    if [ "$home_owner_uid" != "$current_uid" ]; then
        echo "AGENT_SANDBOX_HOME is owned by uid $home_owner_uid, expected $current_uid: $tmp_home" >&2
        exit 1
    fi
    if [ ! -w "$tmp_home" ]; then
        echo "AGENT_SANDBOX_HOME is not writable: $tmp_home" >&2
        exit 1
    fi
    chmod 700 "$tmp_home"
else
    install -d -m 700 "$tmp_home"
fi

install -d -m 700 \
    "$tmp_home/.cache" \
    "$tmp_home/.cache/zsh" \
    "$tmp_home/.claude" \
    "$tmp_home/.codex" \
    "$tmp_home/.config" \
    "$tmp_home/.config/nix" \
    "$tmp_home/.gemini" \
    "$tmp_home/.local/share" \
    "$tmp_home/.local/share/pnpm" \
    "$tmp_home/venv"

if [ ! -e "$tmp_home/.config/starship.toml" ]; then
    install -m 600 "$SANDBOX_STARSHIP_TEMPLATE" "$tmp_home/.config/starship.toml"
    echo "installed starship setting file"
fi

if [ ! -e "$tmp_home/.zshrc" ]; then
    install -m 600 "$SANDBOX_ZSHRC_TEMPLATE" "$tmp_home/.zshrc"
    echo "installed zshrc file"
fi

install -m 600 "$SANDBOX_NIX_CONF_TEMPLATE" "$tmp_home/.config/nix/nix.conf"

codex_auth_args=()
if [ -f "$host_home/.codex/auth.json" ]; then
    touch "$tmp_home/.codex/auth.json"
    codex_auth_args+=(
        --bind "$host_home/.codex/auth.json" /home/agent/.codex/auth.json
    )
fi

claude_auth_args=()
if [ -f "$host_home/.claude/.credentials.json" ]; then
    touch "$tmp_home/.claude/.credentials.json"
    claude_auth_args+=(
        --bind "$host_home/.claude/.credentials.json" /home/agent/.claude/.credentials.json
    )
fi

gemini_auth_args=()
if [ -f "$host_home/.gemini/oauth_creds.json" ]; then
    touch "$tmp_home/.gemini/oauth_creds.json"
    touch "$tmp_home/.gemini/settings.json"
    gemini_auth_args+=(
        --bind "$host_home/.gemini/oauth_creds.json" /home/agent/.gemini/oauth_creds.json
        --bind "$host_home/.gemini/settings.json" /home/agent/.gemini/settings.json
    )
fi

exec bwrap \
    --die-with-parent \
    --unshare-user \
    --unshare-ipc \
    --unshare-pid \
    --unshare-uts \
    --clearenv \
    --dir /bin \
    --dir /lib64 \
    --symlink "$SANDBOX_BASH" /bin/sh \
    --ro-bind /nix /nix \
    --ro-bind-try /lib64 /lib64 \
    --ro-bind-try /run/current-system /run/current-system \
    --proc /proc \
    --dev /dev \
    --ro-bind-try /etc/resolv.conf /etc/resolv.conf \
    --ro-bind-try /etc/hosts /etc/hosts \
    --ro-bind-try /etc/nsswitch.conf /etc/nsswitch.conf \
    --bind "$PWD" /workspace \
    --bind "$tmp_home" /home/agent \
    "${codex_auth_args[@]}" \
    "${claude_auth_args[@]}" \
    "${gemini_auth_args[@]}" \
    --tmpfs /tmp \
    --setenv HOME /home/agent \
    --setenv USER agent \
    --setenv LOGNAME agent \
    --setenv SHELL "$SANDBOX_ZSH" \
    --setenv TERM "xterm-256color" \
    --setenv COLORTERM "truecolor" \
    --setenv PATH "$PATH" \
    --setenv SSL_CERT_FILE "$SANDBOX_CACERT" \
    --setenv NIX_SSL_CERT_FILE "$SANDBOX_CACERT" \
    --setenv XDG_CACHE_HOME /home/agent/.cache \
    --setenv XDG_CONFIG_HOME /home/agent/.config \
    --setenv XDG_DATA_HOME /home/agent/.local/share \
    --setenv GIT_CONFIG_GLOBAL /dev/null \
    --setenv STARSHIP_BIN "$STARSHIP_BIN" \
    --setenv UV_PROJECT_ENVIRONMENT /home/agent/venv/${PROJECT_NAME} \
    --setenv UV_PYTHON_INSTALL_DIR /home/agent/.local/share/uv/python \
    --chdir /workspace \
    "$SANDBOX_ZSH" -i
