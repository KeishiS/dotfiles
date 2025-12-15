{ ... }:
let
  theme = (import ../theme);
in
{
  programs.rio = {
    enable = true;
    settings = {
      confirmbefore-quit = false;
      cursor.shape = "beam";
      editor.program = "hx";
      fonts = {
        size = 22;
        family = theme.font.console;
      };
      window = {
        opacity = 0.7;
        blur = true;
      };
      colors = {
        # Base colors
        background = theme.background;
        foreground = theme.foreground;

        # Regular colors (ANSI 0-7)
        black = theme.palette.black;
        red = theme.palette.red;
        green = theme.palette.green;
        yellow = theme.palette.yellow;
        blue = theme.palette.blue;
        magenta = theme.palette.magenta;
        cyan = theme.palette.cyan;
        white = theme.palette.white;

        # Bright colors (ANSI 8-15)
        light-black = theme.palette.bright-black;
        light-red = theme.palette.bright-red;
        light-green = theme.palette.bright-green;
        light-yellow = theme.palette.bright-yellow;
        light-blue = theme.palette.bright-blue;
        light-magenta = theme.palette.bright-magenta;
        light-cyan = theme.palette.bright-cyan;
        light-white = theme.palette.bright-white;
        light-foreground = theme.palette.bright-white;

        # Cursor
        cursor = theme.cursor.normal;
        vi-cursor = theme.cursor.vi;

        # Navigation/Tabs
        tabs = theme.tabs.background;
        tabs-foreground = theme.tabs.foreground;
        tabs-active = theme.tabs.active.background;
        tabs-active-highlight = theme.tabs.active.highlight;
        tabs-active-foreground = theme.tabs.active.foreground;
        bar = theme.bar;
        split = theme.split;

        # Search
        search-match-background = theme.search.match.background;
        search-match-foreground = theme.search.match.foreground;
        search-focused-match-background = theme.search.focused.background;
        search-focused-match-foreground = theme.search.focused.foreground;

        # Selection
        selection-foreground = theme.selection.foreground;
        selection-background = theme.selection.background;

        # Dim colors
        dim-black = theme.palette.dim-black;
        dim-red = theme.palette.dim-red;
        dim-green = theme.palette.dim-green;
        dim-yellow = theme.palette.dim-yellow;
        dim-blue = theme.palette.dim-blue;
        dim-magenta = theme.palette.dim-magenta;
        dim-cyan = theme.palette.dim-cyan;
        dim-white = theme.palette.dim-white;
        dim-foreground = theme.palette.dim-white;
      };
    };
  };
}
