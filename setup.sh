#!/bin/bash

# set a flag for displaying commands to execute
# set -x

files=(
    ".latexmkrc"
    ".gitconfig"
    ".gitconfig_nobuta05"
    ".nanorc"
    ".zprofile"
    ".zshenv"
    ".zshrc"
    ".config/user-dirs.dirs"
    ".config/starship.toml"
    ".config/autostart/gnome-keyring-ssh.desktop"
    ".config/autostart/insync.desktop"
    ".julia/config/startup.jl"
)

dirs=(
    ".config/nvim"
    ".config/wezterm"
    ".config/fontconfig"
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
