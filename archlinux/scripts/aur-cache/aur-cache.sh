#!/usr/bin/bash

# set -x

WORKDIR=`mktemp -d /tmp/aur-cache-XXXXXX`
OUTDIR=/nfs/archlinux/aur-cache
cd $WORKDIR
pkgs=(
    "1password"
    "electron22-bin"
    "freerouting"
    "gitkraken"
    "google-chrome"
    "insync"
    "keybase-bin"
    "mailspring-bin"
    "midori-bin"
    "nomacs-qt6-git"
    "quarto-cli-bin"
    "rstudio-desktop-bin"
    "sddm-sugar-dark"
    "simplescreenrecorder"
    "slack-desktop-wayland"
    "spleen-font"
    "swaylock-effects"
    "visual-studio-code-bin"
    "otf-source-han-code-jp"
    "ttf-icomoon-feather"
    "ttf-hackgen"
    "ttf-juliamono"
    "ttf-material-design-icons-extended"
    "zoom"
)
for pkg in ${pkgs[@]}; do
    echo "----------[PROCESSING] ${pkg}----------"
    git clone https://aur.archlinux.org/${pkg}.git
    cd ${pkg}
    pkgver=`makepkg --printsrcinfo | grep "pkgver" | awk -F'= ' '{print $2}'`
    pkgrel=`makepkg --printsrcinfo | grep "pkgrel" | awk -F'= ' '{print $2}'`
    ls ${OUTDIR}/${pkg}-${pkgver}-${pkgrel}*.pkg.tar.zst > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        rm ${OUTDIR}/${pkg}*.pkg.tar.zst
        makepkg -sc
        mv *.pkg.tar.zst ${OUTDIR}/
    fi
    cd ..
    rm -rf ${pkg}
done

cd ${OUTDIR}
rm -rf ${WORKDIR}
repo-add aur-cache.db.tar.gz *.pkg.tar.zst
