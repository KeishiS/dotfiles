{ ... }:
let
  theme = (import ../theme);
in
{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;

    settings = {
      font-size = 16;
      font-family = theme.console-font;
      font-feature = "calt";
      background-opacity = 0.7;
      theme = "tokyonight";
      clipboard-paste-protection = false;
      keybind = [
        "ctrl+q=new_tab"
        "ctrl+h=new_split:down"
        "ctrl+v=new_split:right"
        "ctrl+shift+h=goto_split:left"
        "ctrl+shift+l=goto_split:right"
      ];
    };
  };
}
