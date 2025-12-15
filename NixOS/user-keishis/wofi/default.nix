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
        font-family: "${theme.font.console}";
        font-size: 1.5rem;
      }

      window {
        border: 1px solid ${theme.semantic.primary};
        border-radius: 1rem;
        background-color: ${theme.rgba.background-90};
      }

      #outer-box {
        border: none;
      }

      #text {
        color: ${theme.foreground};
      }

      #input {
        color: ${theme.foreground};
        background-color: ${theme.background-alt};
        border: none;
        margin: 1rem;
      }

      #input:selected {
        border: none;
      }

      #inner-box {
        margin: 5px;
        border: none;
      }

      #entry:selected {
        background-color: ${theme.background-highlight};
      }

      #text:selected {
        color: ${theme.semantic.highlight};
      }
    '';
  };
}
