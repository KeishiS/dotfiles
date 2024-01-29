# setfont
sudo pacman -S git fakeroot archlinux-keyring
useradd -g wheel -m arch
EDITOR=nano visudo
su arch
> cd
> git clone https://aur.archlinux.org/spleen-font.git
> cd spleen-font
> makepkg
> sudo pacman -U spleen-font_xxxxx
setfont spleen-16x32

sudo pacstrap -K /mnt base base-devel linux linux-firmware nano git zsh
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
sudo pacman -S networkmanager network-manager-applet lvm2 yubikey-full-disk-encryption
nano /etc/ykfde.conf
> YKFDE_CHALLENGE_PASSWORD_NEEDED="1"
> KYFDE_CHALLENGE_SLOT="1"
nano /etc/mkinitcpio.conf
> `ykfde` を `encrypt` の前に追記
mkinitcpio -p linux
passwd
sudo pacman -S amd-ucode
bootctl install
systemctl enable systemd-boot-update.service
systemctl enable NetworkManager
useradd -m -g wheel -s /usr/bin/zsh keishis
passwd keishis
visudo

# nvidiaの時
pacman -S nvidia nvidia-settings
nano /etc/mkinitcpio.conf # remove `kms` from HOOKS

# amdの時
pacman -S mesa xf86-video-amdgpu rocm-opencl-runtime

nano /boot/loader/entries/arch.conf

nano /etc/fstab
# > /dev/mapper/swap none swap sw 0 0
nano /etc/crypttab
# > swap /dev/mapper/arch-swap /dev/urandom swap,cipher=aes-xts-plain64,size=256
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
systemctl enable sddm
timedatectl set-ntp true

systemctl enable pcscd

#---
nano ~/.vscode/argv.json
# > "password-store": "gnome"
