{ ... }:
let
  theme = import ../theme;
in
{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        opacity = 0.7;
        decorations = "Full";
      };

      scrolling.history = 10000;

      font = {
        size = 16;
        normal.family = theme.font.console;
      };

      cursor.style = {
        shape = "Beam";
        blinking = "Off";
      };

      colors = {
        primary = {
          background = theme.background;
          foreground = theme.foreground;
        };
        cursor = {
          cursor = theme.cursor.normal;
          text = theme.cursor.text;
        };
        selection = {
          background = theme.selection.background;
          text = theme.selection.foreground;
        };
        normal = {
          black = theme.palette."0";
          red = theme.palette."1";
          green = theme.palette."2";
          yellow = theme.palette."3";
          blue = theme.palette."4";
          magenta = theme.palette."5";
          cyan = theme.palette."6";
          white = theme.palette."7";
        };
        bright = {
          black = theme.palette."8";
          red = theme.palette."9";
          green = theme.palette."10";
          yellow = theme.palette."11";
          blue = theme.palette."12";
          magenta = theme.palette."13";
          cyan = theme.palette."14";
          white = theme.palette."15";
        };
        dim = {
          black = theme.palette.dim-black;
          red = theme.palette.dim-red;
          green = theme.palette.dim-green;
          yellow = theme.palette.dim-yellow;
          blue = theme.palette.dim-blue;
          magenta = theme.palette.dim-magenta;
          cyan = theme.palette.dim-cyan;
          white = theme.palette.dim-white;
        };
      };

      # 端末ローカルの操作は Ctrl+Shift に限定し、tmux の Ctrl/Alt と分離する。
      keyboard.bindings = [
        {
          key = "C";
          mods = "Control|Shift";
          action = "Copy";
        }
        {
          key = "V";
          mods = "Control|Shift";
          action = "Paste";
        }
        {
          key = "N";
          mods = "Control|Shift";
          action = "CreateNewWindow";
        }

        # Alacritty の fullscreen より tmux の Alt+Enter を優先する。
        {
          key = "Enter";
          mods = "Alt";
          action = "ReceiveChar";
        }
      ];
    };
  };
}
