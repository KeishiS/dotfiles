{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (git.override { withLibsecret = true; })
    git-crypt
    nano
    ghostty.terminfo
    kitty.terminfo
    alacritty.terminfo
    wezterm.terminfo
    lsof
    curl
    wget
    helix
    nixfmt
    tmux
    gcc
    gfortran
    gnumake
    cmake
    glibc
    zlib
    zip
    unzip
    gptfdisk
    colordiff
    pinentry-curses
    xkeyboard_config # `sway --debug` `xkbcommon: ERROR: couldn't find a Compose file for locale "en_US.UTF-8"`
    home-manager
    pkg-config # for common library directory path, e.g., openssl
    yubikey-manager
    yubikey-personalization # for using `ykchalresp`
    sops

    openblas
  ];

  environment.variables = {
    EDITOR = "hx";
  };
}
