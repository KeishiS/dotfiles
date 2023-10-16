#!/usr/bin/env bash

rofi_command="rofi -theme ~/.config/rofi/screenshot.rasi"

# Options
screen="S"
area="A"
window="W"
cap5="C5"
options="${screen}\n${area}\n${window}\n${cap5}"
chosen=$(echo -e ${options} | ${rofi_command} -dmenu)
