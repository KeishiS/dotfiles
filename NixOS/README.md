# README

自宅サーバの環境構築ファイル群

一時的な鍵生成

```sh
tr -dc '[:graph:]' < /dev/urandom | head -c 256 > luks.key
```

diskoの適用

```sh
nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount <path-to-disk.nix>
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

### リモート更新

```sh
nixos-rebuild switch --flake .#<remote-machine> --target-host <remote-machine> --build-host <remote-machine> --sudo
```

## 指紋認証の設定

```sh
# 指紋を登録(wheelグループのユーザのみ)
fprintd-enroll

# 登録済みの指紋を確認
fprintd-list $USER

# 指紋を削除したい場合
fprintd-delete $USER
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

### 復号後ファイルの掃除

`secrets/` 配下で `*.enc` と `*.enc.*` 以外の通常ファイルを検出・削除するスクリプトを置いている。

```sh
> clean-secrets
> clean-secrets --delete
```

## Mail Notify

Home Manager に `services.mailNotify` モジュールを追加している。アカウントごとに `sops-nix` で秘密情報を復号し、`goimapnotify` を `systemd --user` で常駐させて新着時に `notify-send` を呼ぶ。OAuth2 を有効にした場合は、`refresh_token` から `access_token` を都度取得する。

```nix
services.mailNotify = {
  enable = true;
  accounts.personal = {
    email = "me@example.com";
    host = "imap.gmail.com";
    xoAuth2 = true;
    oauth2 = {
      enable = true;
      clientIdFile = ./sops-nix/secrets/mail-personal-oauth-client-id.enc;
      clientSecretFile = ./sops-nix/secrets/mail-personal-oauth-client-secret.enc;
      refreshTokenFile = ./sops-nix/secrets/mail-personal-oauth-refresh-token.enc;
    };
  };
};
```

OAuth2 で使う暗号化ファイルの中身はそれぞれ 1 行の平文を想定する。

- `clientIdFile`: OAuth client ID
- `clientSecretFile`: OAuth client secret
- `refreshTokenFile`: OAuth refresh token
