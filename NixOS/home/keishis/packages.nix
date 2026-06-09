{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    # Basic utilities
    dex
    file
    jq
    nfs-utils
    pdfgrep
    poppler-utils
    unzip
    ffmpeg

    # GUI Apps
    discord
    firefox
    evince
    gitkraken
    nautilus
    glib
    seahorse
    google-chrome
    pavucontrol
    slack
    # thunderbird-bin
    zoom-us
    _1password-gui
    bitwarden-cli
    # bitwarden-desktop
    nixd
    nixfmt # language server for Nix
    vlc
    insomnia
    jetbrains.datagrip
    dbgate

    kicad
    freerouting
    qmk
    # kdePackages.kdenlive

    # Dev Tools
    cargo-make
    cbc
    glpk
    julia_110-bin
    keybase
    quarto
    R
    rustup
    texliveFull
    typst
    # yarn-berry
    # pipx
    cloud-utils
    gh
    uv
    hugo
    shfmt # for shellscript formatter
    openssl
    pkg-config # for common library directory path, e.g., openssl
    # devpod
    # devpod-desktop
    qemu
    virtiofsd
    terraform

    scrcpy
    # lean4
    elan
  ];
}
