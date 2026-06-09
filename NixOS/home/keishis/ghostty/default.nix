{ ... }:
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
      theme = "Ghostty Default Style Dark";
      cursor-style = "bar";
      clipboard-paste-protection = false;
    };
  };
}
