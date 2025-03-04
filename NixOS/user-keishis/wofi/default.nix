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
        font-size: 1.5rem;
      }

      window {
        border: 1px solid ${theme.primary};
        border-radius: 1rem;
        background-color: ${theme.bg-090};
      }

      #outer-box {
        border: none;
      }

      #text {
        color: ${theme.fg};
      }

      #input { // 入力欄
        color: ${theme.fg};
        background-color: ${theme.bg2};
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
        background-color: ${theme.bg2};
      }

      #text:selected {
        color: ${theme.highlight};
      }
    '';
  };
}
