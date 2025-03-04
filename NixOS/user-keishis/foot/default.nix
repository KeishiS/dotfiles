{ ... }:
let
  theme = (import ../theme);
in
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "${theme.console-font}:size=16";
        bold-text-in-bright = "yes";
      };

      cursor = {
        style = "beam";
        blink = "no";
        beam-thickness = 1.0;
      };

      mouse = {
        hide-when-typing = "yes";
      };

      colors = {
        alpha = 0.7;
      };
    };
  };
}
