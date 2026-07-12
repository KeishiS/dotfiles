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
    nixd # language server for Nix
    nixfmt # formatter for Nix
    vlc
    insomnia
    jetbrains.datagrip
    dbgate

    kicad
    freerouting
    qmk

    # Dev Tools
    cargo-make
    cbc
    glpk
    julia_110-bin
    keybase
    mise
    quarto
    R
    rustup
    texliveFull
    typst
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
    elan
  ];
  # ++ [ pkgs-unstable.bitwarden-desktop ];
}
