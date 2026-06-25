# Nextcloud Media Archive

## Path

- 処理対象: `/storage/nextcloud/data/bcd76067022f35e3705357b03a527034b3aa6c7e6cde28983b73536079ffd658/files/JellyfinImport`
- Jellyfin library 用: `/storage/jellyfin/media/nobuta05`
- ローカル archive: `/storage/archive/nextcloud-media/encrypted/nobuta05`
- 処理済み marker: `/var/lib/nextcloud-media-archive/state/nobuta05`

処理は lenovo で実行する。Nextcloud は calc-serv で動作しているため、
lenovo は NFS 経由で `/storage` を参照する。

Nextcloud 管理下のファイルは読むだけにし、移動・削除・権限変更はしない。
`/storage/jellyfin` と `/storage/archive` 配下の親ディレクトリは calc-serv 側の
`systemd-tmpfiles` で作成する。

## 動作

`nextcloud-media-archive.timer` は 15 分ごとに実行される。

```text
OnCalendar = *:0/15
```

対象は `JellyfinImport` 配下の `.mp4` / `.mkv`。サブディレクトリも再帰的に処理する。
アップロード途中のファイルを避けるため、mtime が 10 分より古いファイルだけを対象にする。

処理内容:

1. Jellyfin 用ディレクトリへ相対パスを維持してコピーする
2. `tar | zstd | age` で暗号化 archive を作成する
3. Backblaze B2 へ upload する
4. marker file を作成する

marker が存在するファイルは再処理しない。

## 権限

NFS 越しでも所有者がずれないように、関連する system user の UID/GID は固定している。

- `nextcloud`: GID `952`
- `jellyfin`: UID/GID `953`
- `nextcloud-media-archive`: UID/GID `954`

## Backblaze

credential file は sops-nix で管理する。

```text
hosts/lenovo/secrets/nextcloud-media-b2.env.enc
```

中身は application key のみ。

```sh
B2_APPLICATION_KEY_ID=...
B2_APPLICATION_KEY=...
```

bucket と prefix は `credentials.nix` の `sandi.backup.b2.targets.nextcloudMedia`
で管理する。

## ローカル保持期間

ローカル archive は `systemd-tmpfiles` により 1 日で削除する。

marker は二重処理防止に必要なので削除しない。

## コマンド

timer 確認:

```sh
systemctl list-timers --all | grep nextcloud-media-archive
```

手動実行:

```sh
sudo systemctl start nextcloud-media-archive.service
sudo journalctl -u nextcloud-media-archive.service -n 100 --no-pager
```

生成物確認:

```sh
find /storage/jellyfin/media/nobuta05 -type f
find /storage/archive/nextcloud-media/encrypted/nobuta05 -type f
find /var/lib/nextcloud-media-archive/state/nobuta05 -type f
```

復号してファイルを取り出す:

```sh
mkdir -p /tmp/nextcloud-media-restore

rage -d -i /path/to/yubikey-identity.txt \
  /storage/archive/nextcloud-media/encrypted/nobuta05/<file>.tar.zst.age \
  | zstd -d \
  | tar -xf - -C /tmp/nextcloud-media-restore
```

再処理したい場合は、対象ファイルに対応する marker を削除してから service を実行する。

```sh
sudo rm /var/lib/nextcloud-media-archive/state/nobuta05/<relative-path>.done
sudo systemctl start nextcloud-media-archive.service
```
