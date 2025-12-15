{ ... }:
let
  theme = (import ../theme);
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = theme.rgb.foreground;
          inner_color = theme.rgb.background;
          outer_color = theme.rgb.primary;
          outline_thickness = 5;
          check_color = theme.semantic.success;
          fail_color = theme.semantic.error;
        }
      ];
    };
  };
}
