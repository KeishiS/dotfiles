#!/usr/bin/bash

set -e
set -x

echo -n "Hostname: " && read hname && echo -e "\n"
echo -n "Password (root): " && read -s pass && echo -e "\n"
echo -n "Password (keishis): " && read -s user_pass && echo -e "\n"

ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
hwclock --systohc
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo -e "KEYMAP=jp106\nXKBLAYOUT=jp" > /etc/vconsole.conf
echo "${hname}" > /etc/hostname

pacman --noconfirm -S networkmanager network-manager-applet lvm2 yubikey-full-disk-encryption
systemctl enable NetworkManager

echo "root:${pass}" | chpasswd
bootctl install
mv /root/ArchLinux.conf /boot/loader/entries/

pacman --noconfirm -S mesa xf86-video-amdgpu rocm-opencl-runtime

echo "swap /dev/mapper/arch-swap /dev/urandom swap,cipher=aes-xts-plain64,size=256" >> /etc/crypttab
echo "/dev/mapper/swap none swap sw 0 0" >> /etc/fstab
echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf
echo -e "[Theme]\nCurrent=sugar-dark" > /etc/sddm.conf

mkinitcpio -p linux

cd /root
pacman --noconfirm -S - < pacman.list
pacman --noconfirm -S rust

systemctl enable pcscd

useradd -m -g wheel -s /usr/bin/zsh keishis
echo "keishis:${user_pass}" | chpasswd
gpasswd -a keishis vboxusers

pacman -S - < /aur-cache.list
echo "FONT=spleen-16x32" >> /etc/vconsole.conf

su - keishis -c "cd ~ && git clone https://github.com/KeishiS/dotfiles && source dotfiles/setup.sh"

echo "1. edit visudo"
echo "2. install paru"
echo '3. "localectl set-x11-keymap jp"'
echo '4. "timedatectl set-ntp true"'
echo '5. enable sddm'

# gpg --export-secret-keys --armor <id> > private.asc
# gpg --export --armor <id> > public.asc
# gpg --import private.asc
# gpg --import public.asc
# gpg --card-status
