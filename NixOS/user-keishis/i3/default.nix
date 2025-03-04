{ pkgs, ... }:
let
  terminal = "ghostty";
  mod = "Mod4";
  theme = (import ../theme);
in {
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = "${mod}";
      terminal = "ghostty";

      startup = [
        { command = "setxkbmap -layout jp"; }
      ];

      keybindings = {
        "${mod} + Return" = "exec ${terminal}";
        "${mod} + Shift + q" = "kill";
        "${mod} + Shift + c" = "reload";
        "${mod} + Shift + r" = "restart";
        "${mod} + d" = "exec rofi -show drun";
        "${mod} + 1" = "workspace number 1";
        "${mod} + 2" = "workspace number 2";
        "${mod} + 3" = "workspace number 3";
        "${mod} + 4" = "workspace number 4";
        "${mod} + 5" = "workspace number 5";
        "${mod} + 6" = "workspace number 6";
        "${mod} + 7" = "workspace number 7";
        "${mod} + 8" = "workspace number 8";
        "${mod} + 9" = "workspace number 9";
        "${mod} + 0" = "workspace number 10";
        "${mod} + Shift + 1" = "move container to workspace number 1";
        "${mod} + Shift + 2" = "move container to workspace number 2";
        "${mod} + Shift + 3" = "move container to workspace number 3";
        "${mod} + Shift + 4" = "move container to workspace number 4";
        "${mod} + Shift + 5" = "move container to workspace number 5";
        "${mod} + Shift + 6" = "move container to workspace number 6";
        "${mod} + Shift + 7" = "move container to workspace number 7";
        "${mod} + Shift + 8" = "move container to workspace number 8";
        "${mod} + Shift + 9" = "move container to workspace number 9";
        "${mod} + Shift + 0" = "move container to workspace number 10";
      };

      gaps = {
        inner = 10;
        outer = 5;
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
            names = [ "Monaspace Krypton" ];
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
