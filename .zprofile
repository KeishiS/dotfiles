export XMODIFIERS="@im=fcitx"
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export BROWSER=$(which google-chrome-stable)
export EDITOR=nvim

if [ -e $HOME/.screenlayout/default.sh ]; then
    source $HOME/.screenlayout/default.sh
fi
