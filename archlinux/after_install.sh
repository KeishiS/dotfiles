#!/usr/bin/bash -e -x

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

localectl set-x11-keymap jp
timedatectl set-ntp true
systemctl enable pcscd

useradd -m -g wheel -s /usr/bin/zsh keishis
echo "keishis:${user_pass}" | chpasswd
gpasswd -a keishis vboxusers

echo "1. install paru"
echo "2. install aur pkgs in dotfiles"
echo "3. execute setup.sh in dotfiles"
