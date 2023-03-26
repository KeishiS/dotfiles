#!/bin/bash

# set a flag for displaying commands to execute
# set -x

files=(
    ".latexmkrc"
    ".Xresources"
    ".tmux.conf"
    ".xprofile"
    ".gitconfig"
    ".gitconfig_nobuta05"
    ".nanorc"
    ".zshenv"
    ".zshrc"
    ".config/user-dirs.dirs"
    ".config/starship.toml"
    ".julia/config/startup.jl"
)

dirs=(
    ".config/i3"
    ".config/alacritty"
    ".config/rofi"
    ".config/nixpkgs"
    ".config/wezterm"
    ".config/fontconfig"
    ".Xresources.d"
)

for file in ${files[@]}; do
    if [[ -e $HOME/dotfiles/${file} ]]; then
        if [[ -L $HOME/${file} ]]; then
            rm $HOME/${file}
        elif [[ -e $HOME/${file} ]]; then
            mv $HOME/${file} $HOME/${file}".bak"
        elif [[ ! -d $(dirname $HOME/${file#/}) ]]; then
            mkdir -p $(dirname $HOME/${file#/})
        fi

        ln -s $HOME/dotfiles/${file} $HOME/${file}
    fi
done

for dir in ${dirs[@]}; do
    if [[ -e $HOME/dotfiles/${dir} ]]; then
        if [[ -L $HOME/${dir} ]]; then
            rm $HOME/${dir}
        elif [[ -e $HOME/${dir} ]]; then
            mv $HOME/${dir%*/} $HOME/${dir%*/}".bak"
        fi
        mkdir -p $HOME/${dir}
        rm -rf $HOME/${dir}

        ln -s $HOME/dotfiles/${dir} $HOME/${dir}
    fi
done

if [[ $(whoami) == "root" ]]; then
    grep -E "blacklist pcspkr" /etc/modprobe.d/nobeep.conf
    if [[ $? -ne 0 ]]; then
        echo "blacklist pcspkr" >>/etc/modprobe.d/nobeep.conf
    fi
fi
