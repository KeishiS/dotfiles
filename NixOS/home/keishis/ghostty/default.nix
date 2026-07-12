{ lib, ... }:
let
  theme = (import ../theme);
in
{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    systemd.enable = false;

    settings = {
      font-size = 16;
      font-family = theme.font.console;
      font-feature = "calt";
      background-opacity = 0.7;
      background-blur = true;

      # 配色は ../theme から生成（rio 等と同一ソース）
      background = theme.background;
      foreground = theme.foreground;
      palette = lib.genList (i: "${toString i}=${theme.palette.${toString i}}") 16;
      cursor-color = theme.cursor.normal;
      cursor-text = theme.cursor.text;
      selection-background = theme.selection.background;
      selection-foreground = theme.selection.foreground;

      cursor-style = "bar";
      clipboard-paste-protection = false;

      keybind = [
        # タブ（zellij の Alt [ / ] とミラー：Ctrl+Shift はローカル，Alt はリモート）
        "ctrl+shift+left_bracket=previous_tab"
        "ctrl+shift+right_bracket=next_tab"
        "ctrl+shift+t=new_tab"
        "ctrl+shift+w=close_surface"

        # ローカル分割（軽用途．本格的な多重化はリモートの zellij に任せる）
        "ctrl+shift+e=new_split:down"
        "ctrl+shift+o=new_split:right"
        "ctrl+shift+z=toggle_split_zoom"

        # Linux デフォルトの alt+1..8 (goto_tab) を解放し，Alt を zellij へ完全透過にする
        "alt+one=unbind"
        "alt+two=unbind"
        "alt+three=unbind"
        "alt+four=unbind"
        "alt+five=unbind"
        "alt+six=unbind"
        "alt+seven=unbind"
        "alt+eight=unbind"
      ];
    };
  };
}
