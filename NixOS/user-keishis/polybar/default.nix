{ ... }:
let
  theme = (import ../theme);
in
{
  services.polybar = {
    enable = true;
    script = "polybar";

    settings = {
      "bar/example" = {
        height = 34;
        radius = 6;

        # Colors
        background = theme.background;
        foreground = theme.foreground;

        # Font
        font-0 = theme.font.console;

        # Modules
        module-margin = 5;
        modules-left = "xworkspaces";
        modules-center = "xwindow";
        modules-right = "battery";

        # Tray
        tray-position = "right";
        tray-background = theme.background-alt;
      };

      "module/xworkspaces" = {
        type = "internal/xworkspaces";

        # Active workspace
        label-active = "%name%";
        label-active-background = theme.semantic.primary;
        label-active-foreground = theme.background;
        label-active-padding = 1;

        # Occupied workspace
        label-occupied = "%name%";
        label-occupied-foreground = theme.foreground;
        label-occupied-padding = 1;

        # Urgent workspace
        label-urgent = "%name%";
        label-urgent-background = theme.semantic.urgent;
        label-urgent-foreground = theme.background;
        label-urgent-padding = 1;

        # Empty workspace
        label-empty = "%name%";
        label-empty-foreground = theme.palette.bright-black;
        label-empty-padding = 1;
      };

      "module/xwindow" = {
        type = "internal/xwindow";
        label = "%title:0:60:...%";
        label-foreground = theme.foreground-alt;
      };

      "module/battery" = {
        type = "internal/battery";
        full-at = 99;
        battery = "BAT0";
        adapter = "AC";

        # Charging
        format-charging = "IN %percentage%%";
        format-charging-foreground = theme.semantic.success;

        # Discharging
        format-discharging = "DIS %percentage%%";
        format-discharging-foreground = theme.foreground;

        # Full
        format-full = "FULL";
        format-full-foreground = theme.semantic.success;

        # Low battery warning
        label-discharging-foreground = theme.semantic.warning;
      };
    };
  };
}
