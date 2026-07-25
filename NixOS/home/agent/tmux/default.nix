{ ... }:
{
  programs.tmux = {
    enable = true;

    keyMode = "vi";
    mouse = true;
    focusEvents = true;
    baseIndex = 1;
    escapeTime = 10;
    historyLimit = 100000;
    terminal = "tmux-256color";

    extraConfig = ''
      set -g renumber-windows on
      # OS クリップボードは外側の端末が所有する。
      set -g set-clipboard off
      set -as terminal-features ',xterm-256color:RGB'

      # キーボード操作は Alt による主要なタブ操作だけを許可する。
      set -g prefix None
      set -g prefix2 None
      unbind -a -T root
      unbind -a -T prefix
      unbind -a -T copy-mode
      unbind -a -T copy-mode-vi
      unbind -aq -T tab
      unbind -aq -T session

      bind -T root M-[ previous-window
      bind -T root M-] next-window
      bind -T root M-1 select-window -t :=1
      bind -T root M-2 select-window -t :=2
      bind -T root M-3 select-window -t :=3
      bind -T root M-4 select-window -t :=4
      bind -T root M-5 select-window -t :=5
      bind -T root M-6 select-window -t :=6
      bind -T root M-7 select-window -t :=7
      bind -T root M-8 select-window -t :=8
      bind -T root M-9 select-window -t :=9
      bind -T root M-t switch-client -T tab
      bind -T root M-o switch-client -T session

      # Alt+t の次の一打だけを Zellij と共通のタブ操作として扱う。
      bind -T tab Escape switch-client -T root
      bind -T tab Enter switch-client -T root
      bind -T tab n new-window -c "#{pane_current_path}"
      bind -T tab x confirm-before -p "Close window #W? (y/n)" kill-window
      bind -T tab r command-prompt -I "#W" "rename-window -- '%%'"
      bind -T tab h previous-window
      bind -T tab l next-window
      bind -T tab i swap-window -d -t -1
      bind -T tab o swap-window -d -t +1

      # Alt+o の次の一打だけを Zellij と共通のセッション操作として扱う。
      bind -T session Escape switch-client -T root
      bind -T session Enter switch-client -T root
      bind -T session d detach-client

      # マウススクロールだけは維持し、クリックやドラッグ操作は許可しない。
      bind -T root WheelUpPane if-shell -F \
        "#{||:#{alternate_on},#{pane_in_mode},#{mouse_any_flag}}" \
        { send-keys -M } { copy-mode -e }
      bind -T copy-mode WheelUpPane send -X -N 5 scroll-up
      bind -T copy-mode WheelDownPane send -X -N 5 scroll-down
      bind -T copy-mode-vi WheelUpPane send -X -N 5 scroll-up
      bind -T copy-mode-vi WheelDownPane send -X -N 5 scroll-down
    '';
  };
}
