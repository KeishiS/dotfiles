{ pkgs, ... }:
let
  theme = (import ../theme);
in
{
  xsession.windowManager.i3 = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "ghostty";

      startup = [
        { command = "setxkbmap -layout jp"; }
      ];

      keybindings = {
        "${modifier} + Return" = "exec ${terminal}";
        "${modifier} + Shift + q" = "kill";
        "${modifier} + Shift + c" = "reload";
        "${modifier} + Shift + r" = "restart";
        "${modifier} + t" = "layout toggle tabbed splith";
        "${modifier} + d" = "exec rofi -show drun";
        "${modifier} + 1" = "workspace number 1";
        "${modifier} + 2" = "workspace number 2";
        "${modifier} + 3" = "workspace number 3";
        "${modifier} + 4" = "workspace number 4";
        "${modifier} + 5" = "workspace number 5";
        "${modifier} + 6" = "workspace number 6";
        "${modifier} + 7" = "workspace number 7";
        "${modifier} + 8" = "workspace number 8";
        "${modifier} + 9" = "workspace number 9";
        "${modifier} + 0" = "workspace number 10";
        "${modifier} + Shift + 1" = "move container to workspace number 1";
        "${modifier} + Shift + 2" = "move container to workspace number 2";
        "${modifier} + Shift + 3" = "move container to workspace number 3";
        "${modifier} + Shift + 4" = "move container to workspace number 4";
        "${modifier} + Shift + 5" = "move container to workspace number 5";
        "${modifier} + Shift + 6" = "move container to workspace number 6";
        "${modifier} + Shift + 7" = "move container to workspace number 7";
        "${modifier} + Shift + 8" = "move container to workspace number 8";
        "${modifier} + Shift + 9" = "move container to workspace number 9";
        "${modifier} + Shift + 0" = "move container to workspace number 10";
      };

      gaps = {
        inner = 2;
        outer = 3;
        # smartGaps = true;
      };

      colors = {
        focused = {
          background = theme.bg;
          border = theme.cyan;
          text = theme.fg;
          indicator = theme.cyan;
          childBorder = theme.blue;
        };
      };

      bars = [
        {
          fonts = {
            names = [ theme.console-font ];
            style = "Light";
            size = 11.0;
          };
          mode = "dock";
          trayOutput = "primary";
          workspaceButtons = true;
          position = "top";
          colors = {
            background = theme.bg;
            statusline = theme.fg;
            separator = theme.border;

            focusedWorkspace = {
              background = theme.primary;
              border = theme.primary;
              text = theme.bg;
            };
            activeWorkspace = {
              background = theme.bg2;
              border = theme.primary;
              text = theme.fg;
            };
            inactiveWorkspace = {
              background = theme.bg;
              border = theme.border;
              text = theme.fg2;
            };
            urgentWorkspace = {
              background = theme.urgent;
              border = theme.urgent;
              text = theme.bg;
            };
            bindingMode = {
              background = theme.accent;
              border = theme.primary;
              text = theme.bg;
            };
          };
        }
      ];

      window = {
        titlebar = false;
      };

      floating = {
        titlebar = false;
      };
    };
  };

  programs.rofi = {
    enable = true;
  };

  home.packages = with pkgs; [
    arandr
  ];
}
