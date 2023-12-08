sudo pacstrap -K /mnt base base-devel linux linux-firmware nano git
genfstab -U /mnt > /mnt/etc/fstab
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
hwclock --systohc
nano /etc/locale.gen # en_US, ja_JP
locale-gen
nano /etc/locale.conf
# > LANG=en_US.UTF-8
nano /etc/vconsole.conf
# > KEYMAP=jp106
# > XKBLAYOUT=jp,us
nano /etc/hostname
nano /etc/pacman.conf
nano /etc/pacman.d/mirrorlist
sudo pacman -S networkmanager network-manager-applet lvm2
nano /etc/mkinitcpio.conf
mkinitcpio -p linux
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

nano /etc/fstab
# > /dev/mapper/swap none swap sw 0 0
nano /etc/crypttab
# > swap /dev/mapper/arch-swap /dev/urandom swap,cipher=aes-xts-plain64,size=512
mkinitcpio -p linux

echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf

git clone https://github.com/KeishiS/dotfiles.git
sudo pacman -S - < dotfiles/pacman.list
install paru
paru -S - < dotfiles/aur.list

nano /etc/vconsole.conf
# > FONT=spleen-16x32
nano /etc/ykfde.conf

#---
nano /etc/sddm.conf
# > [Theme]
# > Current=sugar-dark
localectl set-x11-keymap jp,us
systemctl enable NetworkManager
systemctl start NetworkManager
systemctl enable sddm
timedatectl set-ntp true

systemctl enable pcscd

#---
nano ~/.vscode/argv.json
# > "password-store": "gnome"
