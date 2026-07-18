{ ... }:
{
  programs.zellij = {
    enable = true;
    extraConfig = ''
      show_startup_tips false

      keybinds clear-defaults=true {
          normal {
              bind "Alt h" { MoveFocusOrTab "Left"; }
              bind "Alt j" { MoveFocus "Down"; }
              bind "Alt k" { MoveFocus "Up"; }
              bind "Alt l" { MoveFocusOrTab "Right"; }
              bind "Alt [" { GoToPreviousTab; }
              bind "Alt ]" { GoToNextTab; }
              bind "Alt Enter" { NewPane; }
              bind "Alt z" { ToggleFocusFullscreen; }

              bind "Alt 1" { GoToTab 1; }
              bind "Alt 2" { GoToTab 2; }
              bind "Alt 3" { GoToTab 3; }
              bind "Alt 4" { GoToTab 4; }
              bind "Alt 5" { GoToTab 5; }
              bind "Alt 6" { GoToTab 6; }
              bind "Alt 7" { GoToTab 7; }
              bind "Alt 8" { GoToTab 8; }
              bind "Alt 9" { GoToTab 9; }

              bind "Alt p" { SwitchToMode "pane"; }
              bind "Alt t" { SwitchToMode "tab"; }
              bind "Alt r" { SwitchToMode "resize"; }
              bind "Alt s" { SwitchToMode "scroll"; }
              bind "Alt o" { SwitchToMode "session"; }
              bind "Alt g" { SwitchToMode "locked"; }
          }

          locked {
              bind "Alt g" { SwitchToMode "normal"; }
          }

          pane {
              bind "Esc" "Enter" { SwitchToMode "normal"; }
              bind "h" "Left" { MoveFocus "Left"; }
              bind "j" "Down" { MoveFocus "Down"; }
              bind "k" "Up" { MoveFocus "Up"; }
              bind "l" "Right" { MoveFocus "Right"; }
              bind "n" { NewPane; SwitchToMode "normal"; }
              bind "d" { NewPane "Down"; SwitchToMode "normal"; }
              bind "r" { NewPane "Right"; SwitchToMode "normal"; }
              bind "x" { CloseFocus; SwitchToMode "normal"; }
              bind "f" { ToggleFocusFullscreen; SwitchToMode "normal"; }
          }

          tab {
              bind "Esc" "Enter" { SwitchToMode "normal"; }
              bind "Tab" { GoToNextTab; }
              bind "Backspace" { GoToPreviousTab; }
              bind "n" { NewTab; SwitchToMode "normal"; }
              bind "x" { CloseTab; SwitchToMode "normal"; }
              bind "h" "Left" { GoToPreviousTab; }
              bind "l" "Right" { GoToNextTab; }
          }

          resize {
              bind "Esc" "Enter" { SwitchToMode "normal"; }
              bind "h" "Left" { Resize "Left"; }
              bind "j" "Down" { Resize "Down"; }
              bind "k" "Up" { Resize "Up"; }
              bind "l" "Right" { Resize "Right"; }
              bind "+" "=" { Resize "Increase"; }
              bind "-" { Resize "Decrease"; }
          }

          scroll {
              bind "Esc" "Enter" { SwitchToMode "normal"; }
              bind "j" "Down" { ScrollDown; }
              bind "k" "Up" { ScrollUp; }
              bind "d" { HalfPageScrollDown; }
              bind "u" { HalfPageScrollUp; }
              bind "PageDown" { PageScrollDown; }
              bind "PageUp" { PageScrollUp; }
          }

          session {
              bind "Esc" "Enter" { SwitchToMode "normal"; }
              bind "d" { Detach; }
          }
      }
    '';
  };
}
