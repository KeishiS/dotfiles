sudo pacstrap -K /mnt base base-devel linux linux-firmware nano git
genfstab -U /mnt > /mnt/etc/fstab
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
hwclock --systohc
nano /etc/locale.gen # en_US, ja_JP
locale-gen
nano /etc/locale.conf # LANG=ja_JP.UTF-8
nano /etc/vconsole.conf # KEYMAP=jp106
nano /etc/hostname
nano /etc/pacman.conf
nano /etc/pacman.d/mirrorlist
sudo pacman -S networkmanager network-manager-applet lvm2
nano /etc/mkinitcpio.conf
mkinicpio -p linux
passwd
sudo pacman -S amd-ucode
bootctl install
systemctl enable systemd-boot-update.service
useradd -m -g wheel -s /usr/bin/zsh keishis
passwd keishis
visudo
pacman -S nvidia nvidia-settings
nano /etc/mkinitcpio.conf # remove `kms` from HOOKS
nano /boot/loader/entries/arch.conf

git clone https://github.com/KeishiS/dotfiles.git
sudo pacman -S - < dotfiles/pacman.list
install paru
paru -S - < dotfiles/aur.list

#---
nano /etc/sddm.conf
> [Theme]
> Current=sugar-dark
localectl set-x11-keymap jp,us