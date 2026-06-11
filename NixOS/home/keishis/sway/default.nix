{ config, pkgs, ... }:
let
  theme = (import ../theme);
  powerMenu = pkgs.writeShellScript "sway-powermenu" ''
    lock="Lock"
    logout="Logout"
    suspend="Suspend"
    reboot="Reboot"
    shutdown="Shutdown"

    chosen=$(
      printf "%s\n%s\n%s\n%s\n%s\n" \
        "$lock" \
        "$logout" \
        "$suspend" \
        "$reboot" \
        "$shutdown" |
        ${pkgs.wofi}/bin/wofi --cache-file=/dev/null --dmenu --hide-scroll --insensitive
    )

    case "$chosen" in
      "$lock") ${pkgs.swaylock}/bin/swaylock -C ~/.config/swaylock/config ;;
      "$logout") ${pkgs.sway}/bin/swaymsg exit ;;
      "$suspend") ${pkgs.systemd}/bin/systemctl suspend ;;
      "$reboot") ${pkgs.systemd}/bin/systemctl reboot ;;
      "$shutdown") ${pkgs.systemd}/bin/systemctl poweroff ;;
    esac
  '';
in
{
  wayland.windowManager.sway = {
    enable = true;
    checkConfig = true;
    systemd = {
      enable = true;
      xdgAutostart = true;
    };
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
        "${modifier}+x" = "exec --no-startup-id ${powerMenu}";

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

      bars = [
        # {
        #   command = "waybar";
        # }
      ];

      window.titlebar = false;
      floating.titlebar = false;

      fonts = {
        names = [ theme.font.console ];
        size = 11.0;
      };

      colors = {
        background = theme.background;

        focused = {
          border = theme.semantic.primary;
          childBorder = theme.semantic.primary;
          background = theme.background;
          indicator = theme.palette.cyan;
          text = theme.foreground;
        };

        focusedInactive = {
          border = theme.border;
          childBorder = theme.border;
          background = theme.background-alt;
          indicator = theme.border;
          text = theme.foreground-alt;
        };

        unfocused = {
          border = theme.border;
          childBorder = theme.border;
          background = theme.background-alt;
          indicator = theme.border;
          text = theme.foreground-alt;
        };

        urgent = {
          border = theme.semantic.urgent;
          childBorder = theme.semantic.urgent;
          background = theme.semantic.urgent;
          indicator = theme.semantic.urgent;
          text = theme.background;
        };
      };

      # output."*".bg = "${config.home.homeDirectory}/dotfiles/wallpaper/wallpaper03.png fill";

      startup = [
        { command = "swaybg -m fill -i ${config.home.homeDirectory}/dotfiles/wallpaper/wallpaper03.png"; }
        { command = "fcitx5"; }
        { command = "dex -a"; }
        { command = "swaync"; }
        {
          command = "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP=sway";
        }
        {
          command = "${pkgs.gnupg}/bin/gpg-connect-agent UPDATESTARTUPTTY /bye";
        }
      ];
    };
  };
}
