# README

自宅サーバの環境構築ファイル群

一時的な鍵生成

```sh
tr -dc '[:graph:]' < /dev/urandom | head -c 256 > luks.key
```

## インストール手順

```sh
> # edit disk.nix to replace disk path and a temporary key file path
> nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko <path-to-disk.nix>
> nixos-install --flake .#<machine-name>

> # unmount all partitions
> systemd-cryptenroll --fido2-device=auto --unlock-key-file=<path-to-luks.key> /dev/pool/root

> # 現在のキースロットの確認
> cryptsetup luksDump /dev/pool/root
> cryptsetup luksKillSlot /dev/pool/root <slot-number>
```

## sops-nix

### 追加する公開鍵情報の取得方法

```sh
> ssh-keyscan -t ed25519 <hostname> | ssh-to-age
```

### 公開鍵情報更新後の各暗号ファイルの更新

```sh
> sops updatekeys <file>
```
