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
          font_color = theme.fg-rgb;
          inner_color = theme.bg-rgb;
          outer_color = theme.primary-rgb;
          outline_thickness = 5;
          check_color = theme.yellow;
          fail_color = theme.error;
        }
      ];
    };
  };
}
