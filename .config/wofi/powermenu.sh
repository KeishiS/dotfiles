#!/bin/bash

lock="Lock"
logout="Logout"
suspend="Suspend"
reboot="Reboot"
shutdown="Shutdown"

entries="${lock}\n${logout}\n${suspend}\n${reboot}\n${shutdown}"
chosen=$(echo -e ${entries} | wofi --conf ~/.config/wofi/powermenu.conf --style ~/.config/wofi/style.css)

case ${chosen} in
  $lock)
    swaylock -C ~/.config/swaylock/config
    ;;
  $logout)
    sway exit
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
