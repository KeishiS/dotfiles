{ config, ... }:
let
  theme = (import ../theme);
in
{
  wayland.windowManager.sway = {
    enable = true;
    checkConfig = true;
    config = rec {
      modifier = "Mod4";
      terminal = "ghostty";
      menu = "wofi";
      input."type:keyboard".xkb_layout = "jp";

      defaultWorkspace = "workspace number 1";
      keybindings = {
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+Shift+r" = "reload";
        "${modifier}+Shift+q" = "kill";
        "${modifier}+t" = "layout toggle tabbed splith";
        "${modifier}+f" = "fullscreen toggle";
        "${modifier}+s" = "exec --no-startup-id \"slurp | grim -g - ~/`date +'%Y-%m-%d_%H:%M:%S'.png`\"";
        "${modifier}+d" = "exec --no-startup-id \"wofi -S run\"";
        "${modifier}+x" = "exec --no-startup-id ${config.home.homeDirectory}/.config/wofi/powermenu.sh";

        "XF86MonBrightnessUp" = "exec --no-startup-id brightnessctl s +5%";
        "XF86MonBrightnessDown" = "exec --no-startup-id brightnessctl s 5%-";

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
        outer = 2;
      };

      bars = [ ];

      window.titlebar = false;
      floating.titlebar = false;

      fonts = {
        names = [ theme.console-font ];
        size = 11.0;
      };

      colors = {
        background = theme.bg;

        focused = {
          border = theme.primary;
          childBorder = theme.primary;
          background = theme.bg;
          indicator = theme.secondary;
          text = theme.fg;
        };

        unfocused = {
          border = theme.bg;
          childBorder = theme.bg;
          background = theme.bg;
          indicator = theme.primary;
          text = theme.fg;
        };

        urgent = {
          border = theme.urgent;
          childBorder = theme.urgent;
          background = theme.bg;
          indicator = theme.bg;
          text = theme.fg;
        };
      };

      # output."*".bg = "${config.home.homeDirectory}/dotfiles/wallpaper/wallpaper03.png fill";

      startup = [
        { command = "swaybg -m fill -i ${config.home.homeDirectory}/dotfiles/wallpaper/wallpaper03.png"; }
        { command = "fcitx5"; }
        { command = "dex -a"; }
        { command = "swaync"; }
        { command = "dbus-update-activation-environment --systemd"; }
      ];
    };
    # extraConfig = "WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway";
  };
}
