{ ... }:
let
  theme = (import ../theme);
in
{
  programs.wofi = {
    enable = true;
    settings = { };
    style = ''
      * {
        font-family: "${theme.console-font}";
        font-size: 1rem;
      }
    '';
  };
}
