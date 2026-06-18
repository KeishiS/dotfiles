# home-srv PostgreSQL

## App database 設計

各 app は `prod` と `dev` の 2 つの database を持つ。
また、Atlas の差分計算用に専用の作業 database を持つ。

```text
<app>_prod
<app>_dev
<app>_atlas_dev
```

通常 app database には stage ごとに 5 つの role を用意する。

```text
<app>_<stage>_owner
<app>_<stage>_migrator
<app>_<stage>_app
<app>_<stage>_readonly
<app>_<stage>_operator
```

Atlas 作業 database には同名の login role を用意する。

```text
<app>_atlas_dev
```

例:

```text
keylytix_prod
keylytix_dev
keylytix_atlas_dev

keylytix_prod_owner
keylytix_prod_migrator
keylytix_prod_app
keylytix_prod_readonly
keylytix_prod_operator
keylytix_atlas_dev
```

role の用途:

- `owner`: database object の所有者。`NOLOGIN` とし、人間や app は直接使わない。
- `migrator`: schema migration 用。DDL を実行できる。PgBouncer ではなく PostgreSQL に直結する。
- `app`: app runtime 用。PgBouncer 経由で接続する。
- `readonly`: 開発者や運用者の通常確認用。読み取りのみ。
- `operator`: 運用時のデータ修正用。必要時だけ使う。
- `<app>_atlas_dev`: Atlas 作業 database の owner。実 app database には接続しない。

権限の基本方針:

- `postgres` superuser は app から使わない。
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

PgBouncer は `:6432` で以下に listen する。

```text
localhost
192.168.100.24
100.112.172.58
```

client -> PgBouncer は TLS 必須にし、`db.sandi05.com` の ACME 証明書を使う。
PgBouncer -> PostgreSQL は同一 host の unix socket 経由なので TLS は使わない。
PgBouncer の TLS 初期化が CA file 未指定で失敗するため、client cert 検証用 CA として
system CA bundle を明示する。ただし `client_tls_sslmode = require` なので client
certificate は必須にしない。

pool 設定の初期値:

```text
pool_mode = transaction
max_client_conn = 200
default_pool_size = 10
reserve_pool_size = 5
reserve_pool_timeout = 5
server_idle_timeout = 600
server_lifetime = 3600
```

各 app database には `max_db_connections = 15` を設定する。現在の PgBouncer
対象は `keylytix_prod`, `keylytix_dev`, `koyomado_prod`, `koyomado_dev` なので、
server connection は通常時最大 40、reserve 込み最大 60 を目安にする。
PostgreSQL の `max_connections = 100` に対して、migration や人間の直結用の余裕を残す。

PgBouncer の `auth_file` は sops-nix で管理する。
`hosts/home-srv/postgresql/secrets/pgbouncer-users.enc.txt` に、PgBouncer の
auth file 形式で `*_app` role だけを登録する。

```text
"keylytix_prod_app" "SCRAM-SHA-256$..."
"keylytix_dev_app" "SCRAM-SHA-256$..."
"koyomado_prod_app" "SCRAM-SHA-256$..."
"koyomado_dev_app" "SCRAM-SHA-256$..."
```

PostgreSQL role password と PgBouncer `auth_file` は同じ SCRAM verifier に揃える。
verifier は `postgres` superuser で確認できる。

```sh
sudo -u postgres psql -Atc "
SELECT format('\"%s\" \"%s\"', rolname, rolpassword)
FROM pg_authid
WHERE rolname IN (
  'keylytix_prod_app',
  'keylytix_dev_app',
  'koyomado_prod_app',
  'koyomado_dev_app'
)
ORDER BY rolname;
"
```

各 app の設定は PostgreSQL 基盤配下に分ける。

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

- `<app>_prod` と `<app>_dev` の database を作成する
- Atlas 作業用の `<app>_atlas_dev` database と同名 role を作成する
- stage ごとの 5 role を作成する
- `owner` を `NOLOGIN`、それ以外を `LOGIN` として作成する
- database/schema owner と基本 grant を設定する
- 通常 app database を PostgreSQL backup 対象へ追加する

`<app>_atlas_dev` は Atlas が schema 差分計算に使う空の作業 database なので、
通常 app database と違って app 同名 schema は事前作成しない。また backup 対象にも
含めない。

DB/role は NixOS 側で管理する。Terraform でも PostgreSQL provider で
database/role/grant を管理できるが、接続情報や password が state に残り得る。
この PostgreSQL は NixOS host 内部の service なので、host lifecycle と同じ
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

期待値として `${app}_prod`, `${app}_dev`, `${app}_atlas_dev` が存在する。

role が存在することを確認する。

```sh
sudo -u postgres psql -c "\\du ${app}_*"
```

期待値として stage ごとの role に加えて `${app}_atlas_dev` role が存在する。

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

`public` と app 同名 schema の owner を確認する。

```sh
sudo -u postgres psql -d "$db" -x -v app="$app" -c "
SELECT nspname, pg_get_userbyid(nspowner) AS owner
FROM pg_namespace
WHERE nspname IN ('public', :'app')
ORDER BY nspname;
"
```

期待値:

```text
public owner = <app>_<stage>_owner
<app> owner = <app>_<stage>_owner
```

`public` と app 同名 schema の grant を確認する。

```sh
sudo -u postgres psql -d "$db" -c "\dn+ public"
sudo -u postgres psql -d "$db" -c "\dn+ $app"
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
CREATE TABLE <app>.permission_check (id serial primary key, name text);
```

これは成功する想定。

```sql
RESET ROLE;
SET ROLE <app>_<stage>_app;
INSERT INTO <app>.permission_check (name) VALUES ('ok');
SELECT * FROM <app>.permission_check;
```

`app` role は通常の DML ができる想定。

```sql
RESET ROLE;
SET ROLE <app>_<stage>_readonly;
SELECT * FROM <app>.permission_check;
INSERT INTO <app>.permission_check (name) VALUES ('should_fail');
```

`readonly` role は `SELECT` でき、`INSERT` は失敗する想定。

確認用 table を削除する。

```sql
RESET ROLE;
DROP TABLE <app>.permission_check;
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
REVOKE CONNECT ON DATABASE keylytix_atlas_dev FROM PUBLIC;

SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname IN ('keylytix_prod', 'keylytix_dev', 'keylytix_atlas_dev')
  AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS keylytix_prod;
DROP DATABASE IF EXISTS keylytix_dev;
DROP DATABASE IF EXISTS keylytix_atlas_dev;

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

DROP ROLE IF EXISTS keylytix_atlas_dev;
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

## Backblaze upload 設定

credential file の形式は以下の通り。

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

## Restore 手順

B2 から対象ファイルを取得する。

```sh
b2v4 file download \
  <bucket> \
  <prefix>/<timestamp>/<database>.dump.zst.age \
  /tmp/<database>.dump.zst.age
```

YubiKey recipient で暗号化しているため、identity file を用いて以下のように復号化できる。

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
