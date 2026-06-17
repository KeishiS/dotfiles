manager_env="$("$SYSTEMCTL" --user show-environment 2>/dev/null || true)"

get_manager_env() {
  local name="$1"
  local line

  while IFS= read -r line; do
    case "$line" in
      "$name="*)
        printf '%s\n' "${line#*=}"
        return 0
        ;;
    esac
  done <<< "$manager_env"
}

wayland_display="${WAYLAND_DISPLAY:-$(get_manager_env WAYLAND_DISPLAY)}"
xdg_runtime_dir="${XDG_RUNTIME_DIR:-$(get_manager_env XDG_RUNTIME_DIR)}"
display="${DISPLAY:-$(get_manager_env DISPLAY)}"

case "$wayland_display" in
  /*) wayland_socket="$wayland_display" ;;
  *) wayland_socket="$xdg_runtime_dir/$wayland_display" ;;
esac

if [ -n "$wayland_display" ] && [ -S "$wayland_socket" ]; then
  exec "$PINENTRY_GUI" "$@"
fi

if [ -n "$display" ]; then
  display_num="${display#*:}"
  display_num="${display_num%%.*}"
  if [ -S "/tmp/.X11-unix/X${display_num}" ]; then
    exec "$PINENTRY_GUI" "$@"
  fi
fi

exec "$PINENTRY_TUI" "$@"
