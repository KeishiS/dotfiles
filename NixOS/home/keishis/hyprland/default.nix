{ pkgs, ... }:
let
  powerMenu = pkgs.writeShellScript "hyprland-powermenu" ''
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
      "$lock") ${pkgs.hyprlock}/bin/hyprlock ;;
      "$logout") ${pkgs.hyprland}/bin/hyprctl dispatch exit ;;
      "$suspend") ${pkgs.systemd}/bin/systemctl suspend ;;
      "$reboot") ${pkgs.systemd}/bin/systemctl reboot ;;
      "$shutdown") ${pkgs.systemd}/bin/systemctl poweroff ;;
    esac
  '';

  cheatSheet = pkgs.writeShellScript "hyprland-cheatsheet" ''
    ${pkgs.hyprland}/bin/hyprctl binds -j | ${pkgs.jq}/bin/jq -r '
      def mods($m):
        [ (if ($m / 64 | floor) % 2 == 1 then "SUPER" else empty end),
          (if ($m / 8 | floor) % 2 == 1 then "ALT" else empty end),
          (if ($m / 4 | floor) % 2 == 1 then "CTRL" else empty end),
          (if $m % 2 == 1 then "SHIFT" else empty end)
        ] | join("+");
      .[]
      | (if .modmask > 0 then mods(.modmask) + "+" else "" end)
        + (if .key != "" then .key else "code:" + (.keycode | tostring) end)
        + "\t" + .dispatcher
        + (if .arg != "" then " " + .arg else "" end)
    ' | ${pkgs.wofi}/bin/wofi --cache-file=/dev/null --dmenu --insensitive --prompt "Keybinds" > /dev/null
  '';
in
{
  imports = [
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
  ];

  # Home Manager installs the Hyprland portal backend in ~/.nix-profile.
  # Keep GTK's FileChooser backend in the same profile for portal clients.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    configType = "hyprlang";
    settings = {
      "$mod" = "SUPER";
      "$terminal" = "ghostty";
      bind = [
        "$mod, Return, exec, ghostty"
        "$mod, q, killactive"
        "$mod, d, exec, wofi -S run"
        "$mod, t, togglegroup"
        "$mod, f, fullscreen"
        "$mod, x, exec, ${powerMenu}"
        "$mod, s, exec, slurp | grim -g - ~/`date +'%Y-%m-%d_%H:%M:%S'`.png"
        "$mod, slash, exec, ${cheatSheet}"

        # フォーカス移動・ウィンドウ移動（zellij の Alt+hjkl と同じ語彙）
        "$mod, h, movefocus, l"
        "$mod, j, movefocus, d"
        "$mod, k, movefocus, u"
        "$mod, l, movefocus, r"
        "$mod Shift, h, movewindow, l"
        "$mod Shift, j, movewindow, d"
        "$mod Shift, k, movewindow, u"
        "$mod Shift, l, movewindow, r"

        ", XF86MonBrightnessUp, exec, brightnessctl s +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
        # ", XF86AudioRaiseVolume, exec, pactl -- set-sink-volume 0 -10%"
        # ". XF86AudioLowerVolume, exec, pactl -- set-sink-volume 0 +10%"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        "$mod Shift, 1, movetoworkspace, 1"
        "$mod Shift, 2, movetoworkspace, 2"
        "$mod Shift, 3, movetoworkspace, 3"
        "$mod Shift, 4, movetoworkspace, 4"
        "$mod Shift, 5, movetoworkspace, 5"
        "$mod Shift, 6, movetoworkspace, 6"
        "$mod Shift, 7, movetoworkspace, 7"
        "$mod Shift, 8, movetoworkspace, 8"
        "$mod Shift, 9, movetoworkspace, 9"
        "$mod Shift, 0, movetoworkspace, 10"
      ];
      monitor = [
        ", preferred, auto, 1.0"
      ];
      exec-once = [
        "fcitx5"
        "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE"
        "${pkgs.gnupg}/bin/gpg-connect-agent UPDATESTARTUPTTY /bye"
      ];

      input = {
        kb_layout = "jp";
      };

      general = {
        gaps_out = 5;
      };

      decoration = {
        rounding = 10;
      };
    };

    systemd.enableXdgAutostart = true;
  };
}
