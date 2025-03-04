#!/bin/sh

lock="Lock"
logout="Logout"
suspend="Suspend"
reboot="Reboot"
shutdown="Shutdown"

entries="${lock}\n${logout}\n${suspend}\n${reboot}\n${shutdown}"
chosen=$(echo -e ${entries} | wofi --cache-file=/dev/null --dmenu --hide-scroll --insensitive)

case ${chosen} in
  $lock)
    swaylock -C ~/.config/swaylock/config
    ;;
  $logout)
    swaymsg exit
    ;;
  $suspend)
    ;;
  $reboot)
    systemctl reboot
    ;;
  $shutdown)
    systemctl poweroff
    ;;
esac
