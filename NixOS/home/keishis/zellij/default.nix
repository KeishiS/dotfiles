{ ... }:
{
  programs.zellij = {
    enable = true;
    enableZshIntegration = true;
    attachExistingSession = true;
    exitShellOnExit = true;
    extraConfig = ''
      show_startup_tips false

      keybinds clear-defaults=true {
          normal {
              bind "Alt g" { SwitchToMode "locked"; }
              bind "Alt p" { SwitchToMode "pane"; }
              bind "Alt t" { SwitchToMode "tab"; }
              bind "Alt r" { SwitchToMode "resize"; }
              bind "Alt s" { SwitchToMode "scroll"; }
              bind "Alt o" { SwitchToMode "session"; }

              bind "Alt h" { MoveFocusOrTab "Left"; }
              bind "Alt j" { MoveFocus "Down"; }
              bind "Alt k" { MoveFocus "Up"; }
              bind "Alt l" { MoveFocusOrTab "Right"; }
              bind "Alt n" { NewPane; }
              bind "Alt [" { GoToPreviousTab; }
              bind "Alt ]" { GoToNextTab; }
              bind "Alt f" { ToggleFocusFullscreen; }
              bind "Alt e" { TogglePaneEmbedOrFloating; }
          }

          locked {
              bind "Alt g" { SwitchToMode "normal"; }
          }

          pane {
              bind "Esc" { SwitchToMode "normal"; }
              bind "h" "Left" { MoveFocus "Left"; }
              bind "j" "Down" { MoveFocus "Down"; }
              bind "k" "Up" { MoveFocus "Up"; }
              bind "l" "Right" { MoveFocus "Right"; }
              bind "n" { NewPane; SwitchToMode "normal"; }
              bind "d" { NewPane "Down"; SwitchToMode "normal"; }
              bind "r" { NewPane "Right"; SwitchToMode "normal"; }
              bind "x" { CloseFocus; SwitchToMode "normal"; }
              bind "f" { ToggleFocusFullscreen; SwitchToMode "normal"; }
              bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "normal"; }
          }

          tab {
              bind "Esc" { SwitchToMode "normal"; }
              bind "Tab" { GoToNextTab; }
              bind "Backspace" { GoToPreviousTab; }
              bind "n" { NewTab; SwitchToMode "normal"; }
              bind "x" { CloseTab; SwitchToMode "normal"; }
              bind "h" "Left" { GoToPreviousTab; }
              bind "l" "Right" { GoToNextTab; }
          }

          resize {
              bind "Esc" { SwitchToMode "normal"; }
              bind "h" "Left" { Resize "Left"; }
              bind "j" "Down" { Resize "Down"; }
              bind "k" "Up" { Resize "Up"; }
              bind "l" "Right" { Resize "Right"; }
              bind "+" "=" { Resize "Increase"; }
              bind "-" { Resize "Decrease"; }
          }

          scroll {
              bind "Esc" { SwitchToMode "normal"; }
              bind "j" "Down" { ScrollDown; }
              bind "k" "Up" { ScrollUp; }
              bind "d" { HalfPageScrollDown; }
              bind "u" { HalfPageScrollUp; }
              bind "PageDown" { PageScrollDown; }
              bind "PageUp" { PageScrollUp; }
          }

          session {
              bind "Esc" { SwitchToMode "normal"; }
              bind "d" { Detach; }
          }
      }
    '';
  };
}
