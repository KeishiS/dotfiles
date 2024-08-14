#!/usr/bin/bash

# pacman -Syy
# pacman -S yubikey-full-disk-encryption lvm2 --noconfirm
# # nano /etc/ykfde.conf
# # > YKFDE_CHALLENGE_PASSWORD_NEEDED="1"
# # > YKFDE_CHALLENGE_SLOT="1"
# ykfde-open -d /dev/mapper/arch-root -n root

# mount /dev/mapper/root /mnt
# mkdir -p /mnt/boot
# mount /dev/nvme0n1p1 /mnt/boot

# 1st argument: hostname
echo "length: $#"
hname=$1

echo -n "Password (root): " && read -s pass
echo -n "Password (keishis): " && read -s user_pass

pacstrap -K /mnt base base-devel linux linux-firmware helix git zsh
genfstab -U /mnt > /mnt/etc/fstab

mv /mnt/etc/locale.gen /mnt/etc/locale.gen.old
cp ./configs/locale.gen /mnt/etc/
cp ./configs/pacman.conf /mnt/etc/
cp ./configs/mirrorlist /mnt/etc/pacman.d/
cp ./configs/ykfde.conf /mnt/etc/
cp ./configs/mkinitcpio.conf /mnt/etc/
cp ./configs/ArchLinux.conf /mnt/boot/loader/entries/
cp ./configs/pacman.list /mnt/root/
cp ./after_install.sh /mnt/

arch-chroot /mnt bash after_install.sh
