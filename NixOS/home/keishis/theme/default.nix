rec {
  # ============================================================================
  # Theme: Ghostty Default Style Dark
  # Source: https://github.com/nkxxll/ghostty-default-style-dark.nvim
  # ============================================================================

  name = "Ghostty Default Style Dark";

  # ============================================================================
  # ANSI Color Palette (Standard 16 colors)
  # ============================================================================

  palette = {
    # Regular colors (ANSI 0-7)
    "0" = "#1d1f21";  # black
    "1" = "#cc6566";  # red
    "2" = "#b6bd68";  # green
    "3" = "#f0c674";  # yellow
    "4" = "#82a2be";  # blue
    "5" = "#b294bb";  # magenta
    "6" = "#8abeb7";  # cyan
    "7" = "#c4c8c6";  # white

    # Bright colors (ANSI 8-15)
    "8" = "#666666";   # bright black
    "9" = "#d54e53";   # bright red
    "10" = "#b9ca4b";  # bright green
    "11" = "#e7c547";  # bright yellow
    "12" = "#7aa6da";  # bright blue
    "13" = "#c397d8";  # bright magenta
    "14" = "#70c0b1";  # bright cyan
    "15" = "#eaeaea";  # bright white

    # Named access
    black = palette."0";
    red = palette."1";
    green = palette."2";
    yellow = palette."3";
    blue = palette."4";
    magenta = palette."5";
    cyan = palette."6";
    white = palette."7";

    bright-black = palette."8";
    bright-red = palette."9";
    bright-green = palette."10";
    bright-yellow = palette."11";
    bright-blue = palette."12";
    bright-magenta = palette."13";
    bright-cyan = palette."14";
    bright-white = palette."15";

    # Dim colors (darker variants)
    dim-black = "#1d1f21";
    dim-red = "#a54242";
    dim-green = "#8c9440";
    dim-yellow = "#de935f";
    dim-blue = "#5f819d";
    dim-magenta = "#85678f";
    dim-cyan = "#5e8d87";
    dim-white = "#969896";
  };

  # ============================================================================
  # Base Colors
  # ============================================================================

  background = "#282c34";
  foreground = "#ffffff";
  background-alt = "#1d1f21";        # darker variant
  background-highlight = "#353a44";  # selection/highlight
  foreground-alt = "#c4c8c6";        # palette 7

  # ============================================================================
  # UI Elements
  # ============================================================================

  cursor = {
    normal = foreground;
    vi = palette.bright-magenta;
    text = background-highlight;
  };

  selection = {
    background = foreground;
    foreground = background;
  };

  search = {
    match = {
      background = palette.bright-blue;
      foreground = background;
    };
    focused = {
      background = palette.yellow;
      foreground = background;
    };
  };

  tabs = {
    background = background;
    foreground = palette.bright-black;
    active = {
      background = background-highlight;
      foreground = foreground;
      highlight = palette.yellow;
    };
  };

  border = background-highlight;
  split = background-highlight;
  bar = background-alt;

  # ============================================================================
  # Semantic Colors
  # ============================================================================

  semantic = {
    primary = palette.blue;
    secondary = palette.magenta;
    accent = palette.cyan;
    highlight = palette.yellow;

    success = palette.green;
    error = palette.red;
    warning = palette.yellow;
    info = palette.bright-blue;
    urgent = palette.bright-red;
  };

  # ============================================================================
  # RGB/RGBA Formats
  # ============================================================================

  rgb = {
    foreground = "rgb(255, 255, 255)";
    background = "rgb(40, 44, 52)";
    primary = "rgb(130, 162, 190)";  # semantic.primary (#82a2be)
  };

  rgba = {
    background-80 = "rgba(40, 44, 52, 0.8)";
    background-90 = "rgba(40, 44, 52, 0.9)";
  };

  # ============================================================================
  # Typography
  # ============================================================================

  font = {
    console = "Moralerspace Krypton";
  };
}
