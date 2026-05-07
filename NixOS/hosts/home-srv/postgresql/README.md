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
    common.nix
    keylytix.nix
    koyomado.nix
  secrets/
    <app>-db.env.enc
    pgbouncer-users.enc.txt
```

現在は `keylytix` と `koyomado` を作成対象にしている。

`apps/common.nix` は以下を行う。

- `<app>_prod` と `<app>_dev` の database 作成
- stage ごとの 5 role 作成
- `owner` を `NOLOGIN`、それ以外を `LOGIN` として作成
- database/schema owner と基本 grant の設定
- PostgreSQL backup 対象への追加

DB/role は NixOS 側で管理する。Terraform でも PostgreSQL provider で
database/role/grant を管理できるが、接続情報や password が state に残り得る。
この PostgreSQL は NixOS host 内部のサービスなので、host lifecycle と同じ
NixOS configuration に寄せる。

role password は Nix store に置かない。必要になったら `<app>-db.env.enc` などに
sops-nix で管理する。PgBouncer の `auth_file` も sops-nix で管理する。

### アプリ DB の確認

`<app>` と `<stage>` を指定して、database、role、owner、grant を確認する。

```sh
app=keylytix
stage=prod
db="${app}_${stage}"
```

database が存在することを確認する。

```sh
sudo -u postgres psql -c "\\l ${app}_*"
```

role が存在することを確認する。

```sh
sudo -u postgres psql -c "\\du ${app}_*"
```

role 属性を確認する。

```sh
sudo -u postgres psql -x -v app="$app" -v stage="$stage" -c "
SELECT
  rolname,
  rolcanlogin,
  rolinherit,
  rolsuper,
  rolcreatedb,
  rolcreaterole,
  rolreplication
FROM pg_roles
WHERE rolname ~ ('^' || :'app' || '_' || :'stage' || '_(owner|migrator|app|readonly|operator)$')
ORDER BY rolname;
"
```

期待値:

- `${app}_${stage}_owner`: `rolcanlogin = f`
- `${app}_${stage}_migrator`: `rolcanlogin = t`, `rolinherit = f`
- `${app}_${stage}_app`: `rolcanlogin = t`, `rolinherit = t`
- `${app}_${stage}_readonly`: `rolcanlogin = t`, `rolinherit = t`
- `${app}_${stage}_operator`: `rolcanlogin = t`, `rolinherit = t`
- 全 role: `rolsuper = f`, `rolcreatedb = f`, `rolcreaterole = f`, `rolreplication = f`

database owner を確認する。

```sh
sudo -u postgres psql -x -v db="$db" -c "
SELECT d.datname, r.rolname AS owner
FROM pg_database d
JOIN pg_roles r ON r.oid = d.datdba
WHERE d.datname = :'db';
"
```

期待値:

```text
owner = <app>_<stage>_owner
```

`public` schema の owner を確認する。

```sh
sudo -u postgres psql -d "$db" -x -c "
SELECT nspname, pg_get_userbyid(nspowner) AS owner
FROM pg_namespace
WHERE nspname = 'public';
"
```

期待値:

```text
owner = <app>_<stage>_owner
```

`public` schema の grant を確認する。

```sh
sudo -u postgres psql -d "$db" -c '\dn+ public'
```

期待値:

- `${app}_${stage}_migrator`: `USAGE`, `CREATE`
- `${app}_${stage}_app`: `USAGE`
- `${app}_${stage}_readonly`: `USAGE`
- `${app}_${stage}_operator`: `USAGE`

権限の動作を確認する場合は、password 未設定でも `postgres` から `SET ROLE` で確認できる。

```sh
sudo -u postgres psql -d "$db" -v ON_ERROR_STOP=1
```

```sql
SET ROLE <app>_<stage>_readonly;
CREATE TABLE should_fail (id int);
```

これは失敗するのが正しい。

```sql
RESET ROLE;
SET ROLE <app>_<stage>_migrator;
CREATE TABLE permission_check (id serial primary key, name text);
```

これは成功する想定。

```sql
RESET ROLE;
SET ROLE <app>_<stage>_app;
INSERT INTO permission_check (name) VALUES ('ok');
SELECT * FROM permission_check;
```

`app` role は通常の DML ができる想定。

```sql
RESET ROLE;
SET ROLE <app>_<stage>_readonly;
SELECT * FROM permission_check;
INSERT INTO permission_check (name) VALUES ('should_fail');
```

`readonly` role は `SELECT` でき、`INSERT` は失敗する想定。

確認用 table を削除する。

```sql
RESET ROLE;
DROP TABLE permission_check;
```

### アプリ DB の削除

アプリを NixOS configuration から外すだけでは、既存の database や role は削除されない。
誤削除を避けるため、削除は明示的に PostgreSQL 上で行う。

まず `hosts/home-srv/postgresql/apps/default.nix` から対象アプリの import を削除して
`nixos-rebuild` を実行する。これにより backup 対象からも外れる。

その後、PostgreSQL 上で database と role を削除する。例として `keylytix` を削除する場合:

```sh
sudo -u postgres psql
```

```sql
REVOKE CONNECT ON DATABASE keylytix_prod FROM PUBLIC;
REVOKE CONNECT ON DATABASE keylytix_dev FROM PUBLIC;

SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname IN ('keylytix_prod', 'keylytix_dev')
  AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS keylytix_prod;
DROP DATABASE IF EXISTS keylytix_dev;

REVOKE keylytix_prod_owner FROM keylytix_prod_migrator;
REVOKE keylytix_dev_owner FROM keylytix_dev_migrator;

DROP ROLE IF EXISTS keylytix_prod_operator;
DROP ROLE IF EXISTS keylytix_prod_readonly;
DROP ROLE IF EXISTS keylytix_prod_app;
DROP ROLE IF EXISTS keylytix_prod_migrator;
DROP ROLE IF EXISTS keylytix_prod_owner;

DROP ROLE IF EXISTS keylytix_dev_operator;
DROP ROLE IF EXISTS keylytix_dev_readonly;
DROP ROLE IF EXISTS keylytix_dev_app;
DROP ROLE IF EXISTS keylytix_dev_migrator;
DROP ROLE IF EXISTS keylytix_dev_owner;
```

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
