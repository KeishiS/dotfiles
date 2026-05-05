{ pkgs, ... }:
let
  theme = import ./theme;
in
{
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.volantes-cursors;
    name = "volantes_cursors";
    size = 24;
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts.monospace = [ "Noto Sans Mono CJK JP" ];
    defaultFonts.sansSerif = [ "Noto Sans CJK JP" ];
    defaultFonts.serif = [ "Noto Serif CJK JP" ];
  };

  gtk = {
    enable = true;
    font.name = theme.font.console;
    theme = {
      package = pkgs.orchis-theme;
      name = "Orchis-Dark";
    };
    iconTheme = {
      package = pkgs.tela-icon-theme;
      name = "Tela-nord-dark";
    };
    cursorTheme = {
      package = pkgs.volantes-cursors;
      name = "volantes_cursors";
    };
    gtk2.extraConfig = ''
      gtk-im-module = fcitx
    '';
    gtk3.extraConfig.gtk-im-module = "fcitx";
    gtk4.extraConfig.gtk-im-module = "fcitx";
  };
}
