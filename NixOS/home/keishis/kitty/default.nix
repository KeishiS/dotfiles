{ ... }:
let
  theme = import ../theme;
in
{
  programs.kitty = {
    enable = true;
    font = {
      name = theme.font.console;
      size = 16;
    };
    shellIntegration = {
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    settings = {
      linux_display_server = "wayland";
      wayland_enable_ime = true;

      background_opacity = 0.8;
      cursor_shape = "beam";
      cursor_blink_interval = 0;
      scrollback_lines = 10000;
      confirm_os_window_close = 0;
      enable_audio_bell = false;

      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_bar_min_tabs = 2;

      foreground = theme.foreground;
      background = theme.background;
      selection_foreground = theme.selection.foreground;
      selection_background = theme.selection.background;
      cursor = theme.cursor.normal;
      cursor_text_color = theme.cursor.text;

      active_tab_foreground = theme.tabs.active.foreground;
      active_tab_background = theme.tabs.active.background;
      inactive_tab_foreground = theme.tabs.foreground;
      inactive_tab_background = theme.tabs.background;
      tab_bar_background = theme.bar;

      color0 = theme.palette."0";
      color1 = theme.palette."1";
      color2 = theme.palette."2";
      color3 = theme.palette."3";
      color4 = theme.palette."4";
      color5 = theme.palette."5";
      color6 = theme.palette."6";
      color7 = theme.palette."7";
      color8 = theme.palette."8";
      color9 = theme.palette."9";
      color10 = theme.palette."10";
      color11 = theme.palette."11";
      color12 = theme.palette."12";
      color13 = theme.palette."13";
      color14 = theme.palette."14";
      color15 = theme.palette."15";
    };
    keybindings = {
      # Local tab operations are owned by Kitty.
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+[" = "previous_tab";
      "ctrl+shift+]" = "next_tab";
      "ctrl+shift+," = "move_tab_backward";
      "ctrl+shift+." = "move_tab_forward";
      "ctrl+shift+w" = "close_tab";
      "ctrl+shift+a" = "set_tab_title";

      # Explicitly pass the Alt namespaces owned by tmux and Zsh through.
      "alt+h" = "no_op";
      "alt+j" = "no_op";
      "alt+k" = "no_op";
      "alt+l" = "no_op";
      "alt+[" = "no_op";
      "alt+]" = "no_op";
      "alt+enter" = "no_op";
      "alt+z" = "no_op";
      "alt+t" = "no_op";
      "alt+1" = "no_op";
      "alt+2" = "no_op";
      "alt+3" = "no_op";
      "alt+4" = "no_op";
      "alt+5" = "no_op";
      "alt+6" = "no_op";
      "alt+7" = "no_op";
      "alt+8" = "no_op";
      "alt+9" = "no_op";
      "alt+f" = "no_op";
      "alt+b" = "no_op";
      "alt+d" = "no_op";
    };
  };
}
