{ ... }:
let
  theme = (import ../theme);
in
{
  programs.wofi = {
    enable = true;
    settings = {
      width = 600;
      height = 400;
      show = "drun";
      prompt = "Search...";
      allow_markup = true;
      allow_images = true;
      insensitive = true;
    };
    style = ''
      * {
        font-family: "${theme.font.console}";
        font-size: 1rem;
      }

      window {
        border: 2px solid ${theme.semantic.primary};
        border-radius: 1rem;
        background-color: ${theme.rgba.background-90};
        backdrop-filter: blur(10px);
      }

      #outer-box {
        padding: 1rem;
        border: none;
      }

      #text {
        color: ${theme.foreground};
        padding: 0.3rem 0.5rem;
      }

      #input {
        color: ${theme.foreground};
        background-color: ${theme.background-alt};
        border: 1px solid ${theme.border};
        border-radius: 0.5rem;
        padding: 0.8rem 1rem;
        margin: 0 0 1rem 0;
        outline: none;
      }

      #input:focus {
        border: 1px solid ${theme.semantic.primary};
      }

      #inner-box {
        border: none;
      }

      #scroll {
        margin: 0;
      }

      #entry {
        padding: 0.5rem;
        border-radius: 0.5rem;
        margin: 0.2rem 0;
        transition: all 0.2s ease;
      }

      #entry:hover {
        background-color: ${theme.background-highlight};
      }

      #entry:selected {
        background-color: ${theme.semantic.primary};
        border-radius: 0.5rem;
      }

      #entry:selected #text {
        color: ${theme.background};
        font-weight: bold;
      }

      #text:selected {
        color: ${theme.background};
      }

      /* Scrollbar styling */
      scrollbar {
        background-color: transparent;
        width: 8px;
      }

      scrollbar slider {
        background-color: ${theme.background-highlight};
        border-radius: 4px;
      }

      scrollbar slider:hover {
        background-color: ${theme.semantic.primary};
      }
    '';
  };
}
