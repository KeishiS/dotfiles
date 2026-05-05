{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.local/bin"
    "$HOME/.local/share/pnpm"
  ];

  home.shellAliases = {
    helix = "hx";
  };

  home.sessionVariables = {
    XCURSOR_THEME = "volantes_cursors";
    # GTK_IM_MODULE = "fcitx";
    GTK_IM_MODULE = lib.mkForce "";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
    ELECTRON_ENABLE_WAYLAND = 0;
    # NIXOS_OZONE_WL = "1"; # これを有効化するとwaylandネイティブなアプリが立ち上がり，日本語入力ができなくなる
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    PNPM_HOME = "/home/keishis/.local/share/pnpm";
  };
}
