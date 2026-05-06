# home-srv PostgreSQL

このディレクトリは、home-srv 上の PostgreSQL を host 共通の基盤サービスとして
管理するための NixOS module です。

## 既存クラスタの削除と再初期化

PostgreSQL のデータ削除は不可逆なので、NixOS rebuild の activation script には
含めません。既存データのバックアップが完了していることを確認してから、対象 host
上で明示的に実行します。

```sh
sudo systemctl stop keylytix-graphql-gateway.target || true
sudo systemctl stop keylytix-user-command-service.target || true
sudo systemctl stop keylytix-user-query-service.target || true
sudo systemctl stop keylytix-auth-service.target || true
sudo systemctl stop postgresql.service
```

退避する場合:

```sh
sudo mv /var/lib/postgresql/18 "/var/lib/postgresql/18.before-reset.$(date -u +%Y%m%dT%H%M%SZ)"
```

完全に削除する場合:

```sh
sudo rm -rf /var/lib/postgresql/18
```

その後、新しい構成を適用します。

```sh
sudo nixos-rebuild switch --flake .#nixos-keishis-home
```

`services.postgresql` が新しい空の cluster を初期化します。アプリケーション用の
database、role、PgBouncer 設定はこの基盤構成には含めず、利用するサービス側の
設計として別途追加します。
