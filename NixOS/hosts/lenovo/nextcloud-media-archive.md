# Nextcloud Media Archive

## Path

- 処理対象: `/storage/nextcloud/data/keishis/files/JellyfinImport`
- Jellyfin library 用: `/storage/jellyfin/media/keishis`
- ローカル archive: `/storage/archive/nextcloud-media/encrypted/keishis`
- 処理済み marker: `/var/lib/nextcloud-media-archive/state/keishis`

Nextcloud 管理下のファイルは読むだけにし、移動・削除・権限変更はしない。

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
find /storage/jellyfin/media/keishis -type f
find /storage/archive/nextcloud-media/encrypted/keishis -type f
find /var/lib/nextcloud-media-archive/state/keishis -type f
```

復号テスト:

```sh
rage -d -i /path/to/yubikey-identity.txt \
  /storage/archive/nextcloud-media/encrypted/keishis/<file>.tar.zst.age \
  | zstd -d \
  | tar -tf -
```

再処理したい場合は、対象ファイルに対応する marker を削除してから service を実行する。

```sh
sudo rm /var/lib/nextcloud-media-archive/state/keishis/<relative-path>.done
sudo systemctl start nextcloud-media-archive.service
```
