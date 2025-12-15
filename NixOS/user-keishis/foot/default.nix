{ ... }:
let
  theme = (import ../theme);
in
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "${theme.font.console}:size=16";
        bold-text-in-bright = "yes";
      };

      cursor = {
        style = "beam";
        blink = "no";
        beam-thickness = 1.0;
        color = "${theme.background} ${theme.cursor.normal}";
      };

      mouse = {
        hide-when-typing = "yes";
      };

      colors = {
        alpha = 0.7;

        # Base colors
        background = theme.background;
        foreground = theme.foreground;

        # Selection
        selection-foreground = theme.selection.foreground;
        selection-background = theme.selection.background;

        # Regular colors (ANSI 0-7)
        regular0 = theme.palette."0";   # black
        regular1 = theme.palette."1";   # red
        regular2 = theme.palette."2";   # green
        regular3 = theme.palette."3";   # yellow
        regular4 = theme.palette."4";   # blue
        regular5 = theme.palette."5";   # magenta
        regular6 = theme.palette."6";   # cyan
        regular7 = theme.palette."7";   # white

        # Bright colors (ANSI 8-15)
        bright0 = theme.palette."8";    # bright black
        bright1 = theme.palette."9";    # bright red
        bright2 = theme.palette."10";   # bright green
        bright3 = theme.palette."11";   # bright yellow
        bright4 = theme.palette."12";   # bright blue
        bright5 = theme.palette."13";   # bright magenta
        bright6 = theme.palette."14";   # bright cyan
        bright7 = theme.palette."15";   # bright white

        # Dim colors (optional, for dim mode)
        dim0 = theme.palette.dim-black;
        dim1 = theme.palette.dim-red;
        dim2 = theme.palette.dim-green;
        dim3 = theme.palette.dim-yellow;
        dim4 = theme.palette.dim-blue;
        dim5 = theme.palette.dim-magenta;
        dim6 = theme.palette.dim-cyan;
        dim7 = theme.palette.dim-white;
      };
    };
  };
}
