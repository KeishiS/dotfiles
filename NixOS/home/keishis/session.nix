{ config, pkgs, ... }:
{
  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.local/bin"
    "$HOME/.local/share/pnpm/bin"
  ];

  home.shellAliases = {
    helix = "hx";
  };

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";

    XCURSOR_THEME = "volantes_cursors";
    XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
    ELECTRON_ENABLE_WAYLAND = 0;
    # NIXOS_OZONE_WL = "1"; # これを有効化するとwaylandネイティブなアプリが立ち上がり，日本語入力ができなくなる
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    PNPM_HOME = "${config.home.homeDirectory}/.local/share/pnpm";
  };
}
