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
        font-0 = theme.console-font;
        module-margin = 5;
        modules-left = "xworkspaces";
        modules-center = "xwindow";
        modules-right = "battery";
        tray-position = "right";
      };

      "module/xworkspaces" = {
        type = "internal/xworkspaces";
        label-active = "%name%";
        label-active-background = theme.primary;
        label-active-padding = 1;

        label-urgent-background = theme.urgent;
      };

      "module/xwindow" = {
        type = "internal/xwindow";
        label = "%title:0:60:...%";
      };

      "module/battery" = {
        type = "internal/battery";
        full-at = 99;
        battery = "BAT0";
        adapter = "AC";

        format-charging = "IN %percentage%%";
        format-discharging = "DIS %percentage%%";
      };
    };
  };
}
