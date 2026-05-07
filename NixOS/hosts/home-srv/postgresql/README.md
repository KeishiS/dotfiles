# home-srv PostgreSQL

## App database design

各アプリは `prod` と `dev` の 2 つの database を持つ。

```text
<app>_prod
<app>_dev
```

各 database には stage ごとに 5 つの role を用意する。

```text
<app>_<stage>_owner
<app>_<stage>_migrator
<app>_<stage>_app
<app>_<stage>_readonly
<app>_<stage>_operator
```

例:

```text
keylytix_prod
keylytix_dev

keylytix_prod_owner
keylytix_prod_migrator
keylytix_prod_app
keylytix_prod_readonly
keylytix_prod_operator
```

role の用途:

- `owner`: database object の所有者。`NOLOGIN` とし、人間やアプリは直接使わない。
- `migrator`: schema migration 用。DDL を実行できる。PgBouncer ではなく PostgreSQL に直結する。
- `app`: アプリ runtime 用。PgBouncer 経由で接続する。
- `readonly`: 開発者や運用者の通常確認用。読み取りのみ。
- `operator`: 運用時のデータ修正用。必要時だけ使う。

権限の基本方針:

- `postgres` superuser はアプリから使わない。
- `owner` は object ownership を固定するための role であり、`LOGIN` させない。
- `migrator` は migration 実行時だけ使う。
- `app` は runtime の DML 用に限定する。
- `readonly` は本番調査の通常経路にする。
- `operator` は本番データ修正など、明示的な運用作業に限って使う。

接続経路:

```text
runtime:
  app service -> PgBouncer :6432 -> <app>_<stage>_app

migration:
  migration job -> PostgreSQL :5432 -> <app>_<stage>_migrator

human read-only:
  developer/operator -> PostgreSQL :5432 -> <app>_<stage>_readonly

human write operation:
  operator -> PostgreSQL :5432 -> <app>_<stage>_operator
```

PgBouncer には runtime 用の `app` role だけを登録する。migration は DDL と
transaction pooling の相性を避けるため PostgreSQL へ直結する。

各アプリの設定は PostgreSQL 基盤配下に分ける。

```text
hosts/home-srv/postgresql/
  apps/
    <app>.nix
  secrets/
    <app>-db.env.enc
    pgbouncer-users.enc.txt
```

`<app>-db.env.enc` には role password など、Nix store に置きたくない値を入れる。
PgBouncer の `auth_file` も sops-nix で管理する。

## Backup

`home-postgresql-backup.service` は以下を実行する。

- `pg_dumpall --globals-only`
- database ごとの `pg_dump --format=custom`
- `zstd` 圧縮
- `age` 暗号化
- Backblaze B2 への upload

timer の次回実行予定は以下で確認する。

```sh
systemctl list-timers --all | grep home-postgresql-backup
```

手動実行:

```sh
sudo systemctl start home-postgresql-backup.service
sudo journalctl -u home-postgresql-backup.service -n 100 --no-pager
```

ローカルの backup は `services.homePostgresqlBackup.localRetention` で指定した期間を過ぎると
`systemd-tmpfiles` によって削除される。デフォルトは `1d`。

## Backblaze upload

credential file の形式は以下の通り．

```sh
B2_APPLICATION_KEY_ID=...
B2_APPLICATION_KEY=...
```

bucket と prefix は `credentials.nix` の `sandi.backup.b2.targets.postgresql`
で管理する。credential file には application key のみを入れる。

sops-nix で復号した env file を使う場合の設定例:

```nix
sops.secrets.postgresql-backup-b2-env = {
  format = "binary";
  sopsFile = ./secrets/b2-credentials.env.enc;
  owner = "postgres";
  group = "postgres";
  mode = "0400";
};

services.homePostgresqlBackup.upload = {
  enable = true;
  environmentFile = config.sops.secrets.postgresql-backup-b2-env.path;
  bucket = config.sandi.backup.b2.targets.postgresql.bucket;
  prefix = config.sandi.backup.b2.targets.postgresql.prefix;
};
```

## Restore

B2 から対象ファイルを取得する。

```sh
b2v4 file download \
  <bucket> \
  <prefix>/<timestamp>/<database>.dump.zst.age \
  /tmp/<database>.dump.zst.age
```

YubiKey recipient で暗号化しているため identity file を用いて以下のように復号化できる．

```sh
rage -d \
  -i /path/to/<yubikey-identity>.txt \
  /tmp/<database>.dump.zst.age \
  | zstd -d \
  > /tmp/<database>.dump
```

dump として読めるか確認する。

```sh
pg_restore --list /tmp/<database>.dump | head
```

復元先 database を作成してから restore する。

```sh
createdb <restore_database>
pg_restore --dbname=<restore_database> /tmp/<database>.dump
```
