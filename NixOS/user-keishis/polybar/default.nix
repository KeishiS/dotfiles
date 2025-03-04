{ ... }:
let
  theme = (import ../theme);
in
{
  services.polybar = {
    enable = true;
    settings = {
      "bar/example" = {
        modules-left = "xworkspaces xwindow";
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
    };
  };
}
