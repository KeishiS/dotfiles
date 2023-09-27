#!/bin/sh

PRIMARY="#0E76A8FF"
PRIMARY_VARIANT="#084D6EFF"
ERROR="#CF6679FF"
BACKGROUND="#121212FF"
ON_BACKGROUND="#FFFFFF40"

i3lock \
    --insidever-color=$PRIMARY \
    --ringver-color=$PRIMARY_VARIANT \
    --insidewrong-color=$ERROR \
    --ringwrong-color=$ERROR \
    --inside-color=$BACKGROUND \
    --ring-color=$PRIMARY \
    --line-color=$BACKGROUND \
    --separator-color=$BACKGROUND \
    --verif-color=$ON_BACKGROUND \
    --wrong-color=$ON_BACKGROUND \
    --time-color=$ON_BACKGROUND \
    --date-color=$ON_BACKGROUND \
    --layout-color=$ON_BACKGROUND \
    --keyhl-color="#084D6EFF" \
    --bshl-color=$ERROR \
    --screen 1 \
    --blur 30 \
    --clock \
    --indicator \
    --time-str="%H:%M:%S" \
    --date-str="%A, %Y-%m-%d" \
    --keylayout 1