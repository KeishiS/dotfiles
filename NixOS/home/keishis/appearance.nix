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
    configFile.moralerspace-krypton-monospace = {
      enable = true;
      priority = 90;
      text = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
        <fontconfig>
          <match target="scan">
            <test name="family" compare="eq">
              <string>Moralerspace Krypton</string>
            </test>
            <edit name="spacing" mode="assign">
              <int>100</int>
            </edit>
          </match>
        </fontconfig>
      '';
    };
  };

  gtk = {
    enable = true;
    gtk4.theme = null;
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
  };

  # FreeDesktop portal / GTK / browsers へ dark mode を伝える
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
