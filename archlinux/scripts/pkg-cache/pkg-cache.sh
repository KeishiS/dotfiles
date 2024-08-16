#!/usr/bin/bash

OUTDIR=/nfs/archlinux

pkgs=(
    "base"
    "base-devel"
    "linux"
    "linux-firmware"
    "git"
    "zsh"
    #
    "adwaita-icon-theme"
    "alacritty"
    "arandr"
    "base-devel"
    "brightnessctl"
    "blas-openblas"
    "blueman"
    "bluez"
    "bluez-utils"
    "clamav"
    "clamtk"
    "cmake"
    "coin-or-cbc"
    "colordiff"
    "cronie"
    "dex"
    "discord"
    "docker"
    "dunst"
    "evince"
    "fd"
    "feh"
    "gcc-fortran"
    "git-lfs"
    "glpk"
    "gnome-keyring"
    "graphviz"
    "helix"
    "http-parser"
    "jq"
    "kicad"
    "kicad-library"
    "kicad-library-3d"
    "less"
    "lxappearance"
    "materia-gtk-theme"
    "nfs-utils"
    "pacman-contrib"
    "parallel"
    "pavucontrol"
    "perl-rename"
    "picom"
    "poppler-data"
    "r"
    "rclone"
    "ripgrep"
    "rxvt-unicode"
    "seahorse"
    "sheldon"
    "starship"
    "thunderbird"
    "thunderbird-i18n-ja"
    "tk"
    "tmux"
    "typst"
    "unzip"
    "vagrant"
    "virtualbox"
    "virtualbox-host-modules-arch"
    "vlc"
    "wget"
    "xdg-desktop-portal-gtk"
    "xdg-desktop-portal-wlr"
    "xdg-user-dirs"
    "xorg-xwayland"
    "xorg-xrdb"
    "libfido2"
    "yubikey-full-disk-encryption"
    "yubikey-manager-qt"
    "xsel"
    "xclip"
    "sway"
    "swaybg"
    "waybar"
    "wofi"
    "kwayland-integration"
    "qt5-wayland"
    "qt6-wayland"
    "grim"
    "slurp"
    "i3-wm"
    "i3status"
    "polybar"
    "rofi"
    "fcitx5-gtk"
    "fcitx5-qt"
    "fcitx5-mozc"
    "fcitx5-configtool"
    "noto-fonts"
    "noto-fonts-cjk"
    "otf-ipaexfont"
    "otf-ipafont"
    "ttf-fira-code"
    "ttf-iosevka-nerd"
    "ttf-jetbrains-mono"
    "ttf-jetbrains-mono-nerd"
    "ttf-nerd-fonts-symbols-mono"
    "ttf-roboto"
    "biber"
    "cpanminus"
    "texlive-basic"
    "texlive-bin"
    "texlive-binextra"
    "texlive-fontsextra"
    "texlive-latex"
    "texlive-latexextra"
    "texlive-luatex"
    "texlive-bibtexextra"
    "texlive-langjapanese"
    "pipewire"
    "pipewire-alsa"
    "pipewire-docs"
    "pipewire-pulse"
    "wireplumber"
)

MIRROR_URLS=(
    "http://jp.mirrors.cicku.me/archlinux"
    "http://mirrors.cat.net/archlinux"
    # "http://ftp.tsukuba.wide.ad.jp/Linux/archlinux"
    "http://ftp.jaist.ac.jp/pub/Linux/ArchLinux"
    # "http://mirror.nishi.network/archlinux"
    "http://www.miraa.jp/archlinux"
    "http://kr.mirrors.cicku.me/archlinux"
)
n_mirrors=${#MIRROR_URLS[@]}
idx=$((RANDOM % n_mirrors + 1))
pacman -Syy

REPOS=("core" "extra" "community")
for repo in ${REPOS[@]}; do
    wget --limit-rate=2m \
        -O ${OUTDIR}/${repo}/x86_64/${repo}.db \
        ${MIRROR_URLS[idx]}/${repo}/os/x86_64/${repo}.db
    wget --limit-rate=2m \
        -O ${OUTDIR}/${repo}/x86_64/${repo}.files \
        ${MIRROR_URLS[idx]}/${repo}/os/x86_64/${repo}.files
done

idx=$((idx % n_mirrors + 1))
for pkg in ${pkgs[@]}; do
    name=`pacman -Si ${pkg} | grep 'Name' | awk -F': ' '{print $NF}'`
    repo=`pacman -Si ${pkg} | grep 'Repository' | awk -F': ' '{print $NF}'`
    arch=`pacman -Si ${pkg} | grep 'Architecture' | awk -F': ' '{print $NF}'`
    pkgver=`pacman -Si ${pkg} | grep 'Version' | awk -F': ' '{print $NF}'`
    filename="${name}-${pkgver}-${arch}.pkg.tar.zst"

    if [[ -z "${name}" ]]; then
        continue
    fi

    if [[ -e ${OUTDIR}/${repo}/x86_64/${filename} ]]; then
        continue
    fi

    rm ${OUTDIR}/${repo}/x86_64/${name}-*.pkg.tar.zst*
    echo "===== [DOWNLOADING] ${MIRROR_URLS[idx]}/${repo}/os/x86_64/${filename} ====="
    wget --limit-rate=2m \
        -P "${OUTDIR}/${repo}/x86_64" \
        "${MIRROR_URLS[idx]}/${repo}/os/x86_64/${filename}"
    wget --limit-rate=2m \
        -P "${OUTDIR}/${repo}/x86_64" \
        "${MIRROR_URLS[idx]}/${repo}/os/x86_64/${filename}.sig"
    idx=$((idx % n_mirrors + 1))
    sleep 5
done
