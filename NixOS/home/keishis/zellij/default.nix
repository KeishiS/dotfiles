{ ... }:
{
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    attachExistingSession = true;
    exitShellOnExit = true;
    extraConfig = ''
      show_startup_tips false

      keybinds {
          normal {
              bind "Alt h" { MoveFocusOrTab "Left"; }
              bind "Alt j" { MoveFocus "Down"; }
              bind "Alt k" { MoveFocus "Up"; }
              bind "Alt l" { MoveFocusOrTab "Right"; }
              bind "Alt n" { NewPane; }
              bind "Alt t" { NewTab; }
              bind "Alt [" { GoToPreviousTab; }
              bind "Alt ]" { GoToNextTab; }
              bind "Alt f" { ToggleFocusFullscreen; }
              bind "Alt e" { TogglePaneEmbedOrFloating; }
          }
      }
    '';
  };
}
