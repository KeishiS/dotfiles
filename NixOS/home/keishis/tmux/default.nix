{ ... }:
{
  programs.tmux = {
    enable = true;

    # Vim の Space leader、fcitx5 で使われやすい Ctrl+Space と分離する。
    # Ctrl+q をもう一度押すと、元の Ctrl+q をペインへ送信できる。
    prefix = "C-q";
    keyMode = "vi";
    mouse = true;
    focusEvents = true;
    baseIndex = 1;
    escapeTime = 10;
    historyLimit = 100000;
    terminal = "tmux-256color";

    extraConfig = ''
      set -g renumber-windows on
      set -g set-clipboard on
      set -as terminal-features ',xterm-256color:RGB'

      # Zellij と同じ Alt 配列。Alt+f/b/d はシェルの単語操作用に空ける。
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R
      bind -n M-[ previous-window
      bind -n M-] next-window
      bind -n M-Enter split-window -c "#{pane_current_path}"
      bind -n M-z resize-pane -Z

      bind -n M-1 select-window -t :=1
      bind -n M-2 select-window -t :=2
      bind -n M-3 select-window -t :=3
      bind -n M-4 select-window -t :=4
      bind -n M-5 select-window -t :=5
      bind -n M-6 select-window -t :=6
      bind -n M-7 select-window -t :=7
      bind -n M-8 select-window -t :=8
      bind -n M-9 select-window -t :=9

      # 低頻度操作は prefix 配下に置き、Vim の通常キーを奪わない。
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # copy-mode も Vim と同じ操作感にする。
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y send -X copy-selection-and-cancel
    '';
  };
}
