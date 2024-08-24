#!/bin/bash

# set a flag for displaying commands to execute
# set -x

files=(
    ".nanorc"
    ".zshrc"
    ".zshenv"
    ".zprofile"
    ".latexmkrc"
    ".gitconfig"
    ".tmux.conf"
    ".Xresources"
    ".gitconfig_nobuta05"
    ".config/user-dirs.dirs"
    ".config/mimeapps.list"
    ".config/starship.toml"
    ".config/autostart/gnome-keyring-ssh.desktop"
    ".config/autostart/insync.desktop"
)

cp_files=(
    ".vscode/argv.json"
)

dirs=(
    ".config/rio"
    ".config/alacritty"
    ".config/helix"
    ".config/i3"
    ".config/dunst"
    ".config/wezterm"
    ".config/polybar"
    ".config/rofi"
    ".config/gtk-2.0"
    ".config/gtk-3.0"
    ".config/fontconfig"
    ".config/sheldon"
    ".config/sway"
    ".config/swaylock"
    ".config/waybar"
    ".config/wofi"
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

for file in ${cp_files[@]}; do
    if [[ -e $HOME/dotfiles ]]; then
        if [[ -L $HOME/${file} ]]; then
            rm $HOME/${file}
        elif [[ -e $HOME/${file} ]]; then
            mv $HOME/${file} $HOME/${file}".bak"
        elif [[ ! -d $(dirname $HOME/${file#/}) ]]; then
            mkdir -p $(dirname $HOME/${file#/})
        fi

        cp $HOME/dotfiles/${file} $HOME/${file}
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
