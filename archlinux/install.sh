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
echo "length: ${$#}"
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

arch-chroot /mnt
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
