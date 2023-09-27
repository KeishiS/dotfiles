sudo pacstrap -K /mnt base base-devel linux linux-firmware nano
genfstab -U /mnt > fstab
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
hwclock --systohc
nano /etc/locale.gen # en_US, ja_JP
locale-gen
nano /etc/locale.conf # LANG=en_US.UTF-8
nano /etc/vconsole.conf # KEYMAP=de-latin1
nano /etc/hostname # arch-keishis-X13
nano /etc/pacman.conf
nano /etc/pacman.d/mirrorlist
sudo pacman -S networkmanager network-manager-applet lvm2
nano /etc/mkinitcpio.conf
mkinicpio -p linux
passwd
sudo pacman -S amd-ucode
bootctl install
systemctl enable systemd-boot-update.service

#---
nano /etc/sddm.conf