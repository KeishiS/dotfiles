# デプロイ

## koyomado-dev backend

`deploy/koyomado-dev/default.nix` は dev backend 用の NixOS systemd service を定義します。

backend は `127.0.0.1:8808` で待ち受けます。

## koyomado-dev Cloudflare Tunnel

`deploy/koyomado-dev/cloudflared.nix` は locally-managed Cloudflare Tunnel を定義します。

前提は以下です。

- tunnel hostname: `dev-api.koyomado.com`
- origin service: `http://127.0.0.1:8808`
- 暗号化済み credentials file: `deploy/koyomado-dev/secrets/koyomado-dev-tunnel-credentials.enc.json`
- flake `specialArgs.koyomadoDevTunnelId`: tunnel UUID

### locally-managed tunnel の初期作成

以下は `cloudflared` を入れたローカル端末で実行します。

```sh
cloudflared tunnel login
```

ブラウザで `koyomado.com` zone を選択します。成功すると、アカウント操作用の証明書が作成されます。

```text
~/.cloudflared/cert.pem
```

tunnel を作成します。

```sh
cloudflared tunnel create koyomado-dev
```

成功すると tunnel UUID が表示され、tunnel 実行用の credentials JSON が作成されます。

```text
~/.cloudflared/<tunnel-uuid>.json
```

DNS route を作成します。

```sh
cloudflared tunnel route dns koyomado-dev dev-api.koyomado.com
```

credentials JSON を sops-nix 用に暗号化します。

```sh
TUNNEL_ID="<tunnel-uuid>"

mkdir -p deploy/koyomado-dev/secrets

sops --encrypt \
  "$HOME/.cloudflared/${TUNNEL_ID}.json" \
  > deploy/koyomado-dev/secrets/koyomado-dev-tunnel-credentials.enc.json
```

暗号化済みファイルが作成されたことを確認したら、追加で作った平文コピーは削除します。
元の `~/.cloudflared/<tunnel-uuid>.json` は、復旧用に残すか、sops 管理へ移した後に削除します。

```sh
rm -f /tmp/koyomado-dev-tunnel-credentials.json
```

### NixOS configuration への組み込み

tunnel UUID を NixOS configuration に渡します。

```nix
specialArgs = {
  koyomadoDevTunnelId = "<tunnel-uuid>";
};
```

dev backend と tunnel の module を import します。

```nix
modules = [
  ./deploy/koyomado-dev
  ./deploy/koyomado-dev/cloudflared.nix
];
```

デプロイします。

```sh
sudo nixos-rebuild switch
```

service の状態を確認します。

```sh
systemctl status "cloudflared-tunnel-${TUNNEL_ID}"
journalctl -u "cloudflared-tunnel-${TUNNEL_ID}" -n 100 --no-pager
```

公開経路を確認します。

```sh
curl -fsS https://dev-api.koyomado.com/healthz
```

### cert.pem の扱い

`~/.cloudflared/cert.pem` は、tunnel 作成や DNS route 作成に使うアカウント単位の credential です。
`<tunnel-uuid>.json` が作成され、sops で暗号化済みであれば、tunnel の実行には不要です。

tunnel 作成と DNS route 作成が完了し、今後すぐに tunnel 管理をしない場合は削除できます。

```sh
rm ~/.cloudflared/cert.pem
```

ローカルファイルを削除しても、credential 自体は revoke されません。revoke したい場合は Cloudflare Dashboard から対応する API token を削除します。

```text
Cloudflare Dashboard -> My Profile -> API Tokens
```

後から tunnel の追加管理が必要になった場合は、再度以下を実行して新しい `cert.pem` を発行します。

```sh
cloudflared tunnel login
```
