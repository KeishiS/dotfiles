# README

自宅サーバの環境構築ファイル群

## ディレクトリ構成

- `hosts/`: マシンごとの差分。hostname、hardware configuration、disk、host 固有 service を置く。
- `modules/base/`: すべての NixOS host に入れる基礎設定。
- `modules/profiles/`: desktop、server、window manager など用途別の組み合わせ。
- `modules/services/`: 再利用する NixOS service module。
- `home/keishis/`: Home Manager 設定。
- `scripts/`: 運用補助スクリプト。

## よく使うコマンド

通常の開発用 shell に入る。

```sh
nix develop .#plain
```

`nix develop` は sandbox 用 entrypoint に入る。`shellHook` を抑止したい場合は以下を使う。

```sh
SKIP_AGENT_BWRAP=1 nix develop
```

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
> # disk.nix の disk path と一時 key file path を編集する
> nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko <path-to-disk.nix>
> nixos-install --flake .#<machine-name>

> # すべての partition を unmount する
> systemd-cryptenroll --fido2-device=auto --unlock-key-file=<path-to-luks.key> /dev/pool/root

> # 現在のキースロットの確認
> cryptsetup luksDump /dev/pool/root
> cryptsetup luksKillSlot /dev/pool/root <slot-number>
```

### リモート更新

```sh
nixos-rebuild switch --flake .#<remote-machine> --target-host <remote-machine> --build-host <remote-machine> --ask-sudo-password
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

暗号化ルールは root の `.sops.yaml` に置いている。
age recipient は各 `nixosConfigurations` 名に対応しており、
host 別の `secrets/` と共有 service module 用の `secrets/` を path regex で分けている。

### 追加する公開鍵情報の取得方法

```sh
> ssh-keyscan -t ed25519 <hostname> | ssh-to-age
```

### 公開鍵情報更新後の各暗号ファイルの更新

更新対象の暗号ファイル一覧は以下で確認できる。

```sh
> list-sops-updatekeys-targets
> list-sops-updatekeys-targets ./hosts/home-srv
```

表示されたファイルを対象に `sops updatekeys` を実行する。

```sh
> sops updatekeys <file>
```

### 復号後ファイルの掃除

`secrets/` 配下で `*.enc` と `*.enc.*` 以外の通常ファイルを検出・削除するスクリプトを置いている。

```sh
> clean-secrets
> clean-secrets --delete
> clean-secrets --delete ./hosts/home-srv
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

## Kanidm / NFS home

Kanidm は `lenovo` を identity server として扱う。URL は `https://id.sandi05.com` で、
LAN 内では各 host の `hosts.local` で `lenovo` の LAN IP に向ける。

### 構成

- `hosts/lenovo/kanidm.nix`: Kanidm server、ACME、nginx reverse proxy の設定。
- `modules/services/kanidm-client/`: Kanidm client 共通設定。`lenovo`、`home-srv`、`n100` で共通利用する。
- `hosts/lenovo/nfs.nix`: `/users` を NFS export する。
- `modules/services/nfs-client/`: NFS client を autofs direct map で mount する共通設定。

Kanidm client は NSS/PAM/SSH authorized keys lookup を提供する。`server-users` group の user は対象 host に login できるが、sudo 権限は付与しない。

home directory は Kanidm client 側では作成・管理しない。`/users` は `lenovo` から NFS で提供し、client 側では autofs で必要時に mount する。そのため client 共通 module では `kanidm-unixd-tasks.service` を無効化している。

### Kanidm provision

`hosts/lenovo/kanidm.nix` では Kanidm の group 設定を一部宣言的に管理する。

- `server-users`: SSH/PAM login を許可する user group。
- `idm_people_self_mail_write`: user が自分の mail address を変更できるようにする Kanidm builtin group。

`server-users` を `idm_people_self_mail_write` の member にすることで、`server-users` に所属する user は自分の mail address を変更できる。

### 新規 user の追加

新規 user を追加する場合は、まず Kanidm で person user を作成する。

```sh
kanidm person create <user> "<Display Name>" \
  -H https://id.sandi05.com \
  -D idm_admin
```

SSH/PAM login を許可する場合は `server-users` に追加する。

```sh
kanidm group add-members server-users <user> \
  -H https://id.sandi05.com \
  -D idm_admin
```

`server-users` は `idm_people_self_mail_write` に所属しているため、この user は自分の mail address を変更できる。

```sh
kanidm person update <user> \
  --mail <user@example.com> \
  -H https://id.sandi05.com \
  -D <user>
```

SSH public key は Kanidm に登録する。

```sh
kanidm person ssh add-publickey --name <user> <user> <key-name> "$(cat ~/.ssh/id_ed25519.pub)" \
  -H https://id.sandi05.com \
  -D <user>
```

home directory は `lenovo` の `/users/<user>` に作成し、owner を Kanidm の UID/GID に合わせる。UID/GID は `getent passwd <user>` で確認する。

```sh
getent passwd <user>
sudo install -d -m 0700 -o <uid> -g <gid> /users/<user>
```

### `/users` の mount

`home-srv` と `n100` では次のように指定する。

```nix
sandi.nfsClient = {
  enable = true;
  mounts.users = {
    mountPoint = "/users";
    remote = "192.168.10.17:/users";
  };
};
```

`modules/services/nfs-client/` は以下をまとめて設定する。

- `nfs-utils` を system と `autofs.service` の PATH に追加する。
- `boot.supportedFilesystems` に `nfs` を追加する。
- autofs の direct map を生成する。
- mount point を `tmpfiles` と `autofs.preStart` で作成する。

`/users` が見えない場合は、まず NFS と autofs を分けて確認する。

```sh
getent passwd keishi
systemctl status autofs --no-pager
sudo systemctl cat autofs
sudo mkdir -p /mnt/test-users
sudo mount -t nfs4 -o vers=4.2 192.168.10.17:/users /mnt/test-users
ls -la /mnt/test-users
sudo umount /mnt/test-users
```

`getent passwd keishi` が通るが `/users` が見えない場合は、Kanidm ではなく NFS/autofs 側の問題として切り分ける。

### 確認手順

各 client host で以下を確認する。

```sh
getent hosts id.sandi05.com
getent passwd keishi
ls -la /users
systemctl status kanidm-unixd --no-pager
systemctl status kanidm-unixd-tasks --no-pager
```

期待値は、`kanidm-unixd` が active、`kanidm-unixd-tasks` が disabled/inactive であること。実 login は以下で確認する。

```sh
ssh keishi@<host>
pwd
ls -la ~
```

`pwd` が `/users/keishi` になればよい。
