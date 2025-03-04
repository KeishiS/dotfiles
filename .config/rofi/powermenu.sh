#!/usr/bin/env bash

# lock=$(echo -ne "\uE897")
# logout=$(echo -ne "\uE9BA")
# sleep=$(echo -ne "\uEF44")
# reboot=$(echo -ne "\uF053")
# poweroff=$(echo -ne "\uE8AC")
# options="${lock}\n${logout}\n${sleep}\n${reboot}\n${poweroff}"

rofi_command="rofi -theme ~/dotfiles/.config/rofi/powermenu.rasi"

# Options
lock=$(echo -ne "Lock")
logout=$(echo -ne "Logout")
suspend=$(echo -ne "Suspend")
reboot=$(echo -ne "Reboot")
shutdown=$(echo -ne "Shutdown")


options="${lock}\n${logout}\n${suspend}\n${reboot}\n${shutdown}"
chosen="$(echo -e "$options" | $rofi_command -p "See You Later" -dmenu)"

case ${chosen} in
    $lock)
        source ~/.config/i3/i3lock-color.sh
        ;;
    $logout)
        i3-msg exit
        ;;
    $suspend)
        systemctl hibernate
        ;;
    $reboot)
        systemctl reboot
        ;;
    $shutdown)
        systemctl poweroff
        ;;
esac
