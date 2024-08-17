#!/usr/bin/bash

# iwctl
# > device list
# > station <device> scan
# > station <device> get-networks
# > station <device> connect <SSID>
# > station <device> show
# > exit

# loadkeys jp106
# pacman -Syy
# pacman --noconfirm -S helix git yubikey-full-disk-encryption
# # nano /etc/ykfde.conf
# # > YKFDE_CHALLENGE_PASSWORD_NEEDED="1"
# # > YKFDE_CHALLENGE_SLOT="1"
# ykfde-open -d /dev/mapper/arch-root -n root

# mount /dev/mapper/root /mnt
# mkdir -p /mnt/boot
# mount /dev/nvme0n1p1 /mnt/boot

cp ./configs/pacman.conf /etc/
cp ./configs/mirrorlist /etc/pacman.d/
pacman -Syy

pacstrap -K /mnt base base-devel linux linux-firmware helix git zsh
genfstab -U /mnt > /mnt/etc/fstab

cp ./configs/locale.gen /mnt/etc/
cp ./configs/pacman.conf /mnt/etc/
cp ./configs/mirrorlist /mnt/etc/pacman.d/
cp ./configs/ykfde.conf /mnt/etc/
cp ./configs/mkinitcpio.conf /mnt/etc/
cp ./configs/ArchLinux.conf /mnt/root/
cp ./configs/pacman.list /mnt/root/
cp ./after_install.sh /mnt/
cp ./configs/aur-cache.list /mnt/

arch-chroot /mnt bash after_install.sh
