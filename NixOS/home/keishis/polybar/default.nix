{ ... }:
let
  theme = (import ../theme);
in
{
  services.polybar = {
    enable = true;
    script = "polybar main";

    settings = {
      "bar/main" = {
        width = "100%";
        height = 30;
        radius = 0;
        fixed-center = true;

        background = theme.background;
        foreground = theme.foreground;

        line-size = 2;
        border-size = 0;
        padding-left = 1;
        padding-right = 1;
        module-margin = 2;

        font-0 = "${theme.font.console}:style=Light:size=10";
        font-1 = "${theme.font.console}:style=Bold:size=10";

        modules-left = "xworkspaces";
        modules-center = "xwindow";
        modules-right = "pulseaudio wlan battery date";

        tray-position = "right";
        tray-background = theme.background;
        tray-padding = 2;
        cursor-click = "pointer";
        cursor-scroll = "ns-resize";
      };

      "module/xworkspaces" = {
        type = "internal/xworkspaces";

        label-active = "%name%";
        label-active-background = theme.semantic.primary;
        label-active-foreground = theme.background;
        label-active-padding = 2;
        label-active-underline = theme.semantic.highlight;

        label-occupied = "%name%";
        label-occupied-foreground = theme.foreground;
        label-occupied-padding = 2;

        label-urgent = "%name%";
        label-urgent-background = theme.semantic.urgent;
        label-urgent-foreground = theme.background;
        label-urgent-padding = 2;

        label-empty = "%name%";
        label-empty-foreground = theme.palette.bright-black;
        label-empty-padding = 2;
      };

      "module/xwindow" = {
        type = "internal/xwindow";
        label = "%title:0:80:...%";
        label-foreground = theme.foreground-alt;
      };

      "module/date" = {
        type = "internal/date";
        interval = 5;
        date = "%Y-%m-%d";
        time = "%H:%M";
        label = "%date% %time%";
        label-foreground = theme.foreground;
      };

      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        format-volume = "VOL <label-volume>";
        label-volume = "%percentage%%";
        label-muted = "MUTE";
        label-muted-foreground = theme.semantic.warning;
      };

      "module/wlan" = {
        type = "internal/network";
        interface-type = "wireless";
        interval = 3;
        format-connected = "NET <label-connected>";
        label-connected = "%essid%";
        label-connected-foreground = theme.foreground-alt;
        format-disconnected = "NET down";
        format-disconnected-foreground = theme.palette.bright-black;
      };

      "module/battery" = {
        type = "internal/battery";
        full-at = 99;
        battery = "BAT0";
        adapter = "AC";

        format-charging = "BAT +%percentage%%";
        format-charging-foreground = theme.semantic.success;

        format-discharging = "BAT %percentage%%";
        format-discharging-foreground = theme.foreground;

        format-full = "BAT full";
        format-full-foreground = theme.semantic.success;

        label-discharging-foreground = theme.semantic.warning;
      };
    };
  };
}
