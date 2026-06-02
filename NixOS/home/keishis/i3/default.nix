{ pkgs, config, ... }:
let
  theme = (import ../theme);
  screenshot = "maim -s ${config.home.homeDirectory}/Pictures/`date +'%Y-%m-%d_%H:%M:%S'`.png";
  launchPolybar = pkgs.writeShellScript "launch-polybar" ''
    ${pkgs.polybar}/bin/polybar-msg quit >/dev/null 2>&1 || true
    ${pkgs.polybar}/bin/polybar main &
  '';
  powerMenu = pkgs.writeShellScript "i3-powermenu" ''
    choice=$(
      printf "lock\nlogout\nsuspend\nreboot\npoweroff\n" | ${pkgs.rofi}/bin/rofi \
        -dmenu \
        -i \
        -p "session" \
        -theme-str 'window { width: 320px; border: 2px; border-color: ${theme.semantic.primary}; background-color: ${theme.background}; }' \
        -theme-str 'mainbox { padding: 12px; background-color: ${theme.background}; }' \
        -theme-str 'inputbar { padding: 8px; margin: 0 0 8px 0; background-color: ${theme.background-alt}; text-color: ${theme.foreground}; }' \
        -theme-str 'listview { lines: 5; fixed-height: true; background-color: ${theme.background}; }' \
        -theme-str 'element { padding: 8px; background-color: ${theme.background}; text-color: ${theme.foreground-alt}; }' \
        -theme-str 'element selected { background-color: ${theme.semantic.primary}; text-color: ${theme.background}; }'
    )

    case "$choice" in
      lock) ${pkgs.systemd}/bin/loginctl lock-session ;;
      logout) ${pkgs.i3}/bin/i3-msg exit ;;
      suspend) ${pkgs.systemd}/bin/systemctl suspend ;;
      reboot) ${pkgs.systemd}/bin/systemctl reboot ;;
      poweroff) ${pkgs.systemd}/bin/systemctl poweroff ;;
    esac
  '';
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
      menu = "rofi -show drun";
      defaultWorkspace = "workspace number 1";

      startup = [
        {
          command = "setxkbmap -layout jp";
          always = true;
          notification = false;
        }
        {
          command = "feh --bg-fill ${config.home.homeDirectory}/dotfiles/wallpaper/wallpaper03.png";
          always = true;
          notification = false;
        }
        {
          command = "fcitx5";
          notification = false;
        }
        {
          command = "nm-applet";
          notification = false;
        }
        {
          command = "swaync";
          notification = false;
        }
        {
          command = "${launchPolybar}";
          always = true;
          notification = false;
        }
      ];

      keybindings = {
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+Shift+q" = "kill";
        "${modifier}+Shift+c" = "reload";
        "${modifier}+Shift+r" = "restart";
        "${modifier}+x" = "exec --no-startup-id ${powerMenu}";
        "${modifier}+t" = "layout toggle tabbed splith";
        "${modifier}+f" = "fullscreen toggle";
        "${modifier}+space" = "floating toggle";
        "${modifier}+Shift+space" = "focus mode_toggle";
        "${modifier}+d" = "exec ${menu}";
        "${modifier}+s" = "exec --no-startup-id ${screenshot}";
        "${modifier}+Shift+e" = ''
          exec --no-startup-id i3-nagbar -t warning -m "Exit i3?" \
            -B "Logout" "i3-msg exit"
        '';
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
        "${modifier}+r" = "mode resize";
      };

      gaps = {
        inner = 6;
        outer = 4;
      };

      modes.resize = {
        "h" = "resize shrink width 10 px or 10 ppt";
        "j" = "resize grow height 10 px or 10 ppt";
        "k" = "resize shrink height 10 px or 10 ppt";
        "l" = "resize grow width 10 px or 10 ppt";
        "Left" = "resize shrink width 10 px or 10 ppt";
        "Down" = "resize grow height 10 px or 10 ppt";
        "Up" = "resize shrink height 10 px or 10 ppt";
        "Right" = "resize grow width 10 px or 10 ppt";
        "Return" = "mode default";
        "Escape" = "mode default";
        "${modifier}+r" = "mode default";
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

      bars = [ ];

      window = {
        titlebar = false;
      };

      floating = {
        titlebar = false;
      };

      focus = {
        followMouse = true;
        mouseWarping = true;
      };

      assigns = {
        "workspace number 2" = [ { class = "firefox"; } ];
        "workspace number 9" = [ { class = "1Password"; } ];
      };
    };
  };

  programs.rofi = {
    enable = true;
    theme = "Arc-Dark";
  };

  home.packages = with pkgs; [
    arandr
    feh
    maim
    polybar
    xclip
  ];
}
