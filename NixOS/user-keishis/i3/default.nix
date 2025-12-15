{ pkgs, config, ... }:
let
  theme = (import ../theme);
in
{
  imports = [
    ../polybar
  ];

  xsession.windowManager.i3 = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "ghostty";
      defaultWorkspace = "workspace number 1";

      startup = [
        {
          command = "setxkbmap -layout jp";
          always = true;
          notification = false;
        }
      ];

      keybindings = {
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+Shift+q" = "kill";
        "${modifier}+Shift+c" = "reload";
        "${modifier}+Shift+r" = "restart";
        "${modifier}+x" =
          "exec --no-startup-id ${config.home.homeDirectory}/dotfiles/.config/rofi/powermenu.sh";
        "${modifier}+t" = "layout toggle tabbed splith";
        "${modifier}+d" = "exec rofi -show drun";
        "${modifier}+1" = "workspace number 1";
        "${modifier}+2" = "workspace number 2";
        "${modifier}+3" = "workspace number 3";
        "${modifier}+4" = "workspace number 4";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace number 9";
        "${modifier}+0" = "workspace number 10";
        "${modifier}+Shift+1" = "move container to workspace number 1";
        "${modifier}+Shift+2" = "move container to workspace number 2";
        "${modifier}+Shift+3" = "move container to workspace number 3";
        "${modifier}+Shift+4" = "move container to workspace number 4";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace number 9";
        "${modifier}+Shift+0" = "move container to workspace number 10";
      };

      gaps = {
        inner = 2;
        outer = 3;
        # smartGaps = true;
      };

      colors = {
        focused = {
          background = theme.background;
          border = theme.palette.cyan;
          text = theme.foreground;
          indicator = theme.palette.cyan;
          childBorder = theme.semantic.primary;
        };
        unfocused = {
          background = theme.background-alt;
          border = theme.border;
          text = theme.foreground-alt;
          indicator = theme.border;
          childBorder = theme.border;
        };
        focusedInactive = {
          background = theme.background-alt;
          border = theme.border;
          text = theme.foreground-alt;
          indicator = theme.border;
          childBorder = theme.border;
        };
        urgent = {
          background = theme.semantic.urgent;
          border = theme.semantic.urgent;
          text = theme.background;
          indicator = theme.semantic.urgent;
          childBorder = theme.semantic.urgent;
        };
      };

      bars = [
        {
          fonts = {
            names = [ theme.font.console ];
            style = "Light";
            size = 11.0;
          };
          mode = "dock";
          trayOutput = "primary";
          workspaceButtons = true;
          position = "top";
          colors = {
            background = theme.background;
            statusline = theme.foreground;
            separator = theme.border;

            focusedWorkspace = {
              background = theme.semantic.primary;
              border = theme.semantic.primary;
              text = theme.background;
            };
            activeWorkspace = {
              background = theme.background-highlight;
              border = theme.semantic.primary;
              text = theme.foreground;
            };
            inactiveWorkspace = {
              background = theme.background;
              border = theme.border;
              text = theme.palette.bright-black;
            };
            urgentWorkspace = {
              background = theme.semantic.urgent;
              border = theme.semantic.urgent;
              text = theme.background;
            };
            bindingMode = {
              background = theme.semantic.accent;
              border = theme.semantic.primary;
              text = theme.background;
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
    polybar
  ];
}
