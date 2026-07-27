# AIサービス

lenovoでは、Leantime、MariaDB、TriliumNextおよびMarginalisを運用します。
外部公開用のTLS終端はn100が担当し、lenovoのnginxへHTTPで転送します。

## 構成の反映

変更したホストごとに、最初に`test`で確認します。

```console
# calc-serv
sudo nixos-rebuild test --flake .#nixos-sandi-calc-serv

# lenovo
sudo nixos-rebuild test --flake .#nixos-sandi-lenovo

# n100
sudo nixos-rebuild test --flake .#nixos-sandi-n100
```

反映後は、lenovoで次を確認します。

```console
systemctl status mysql leantime-database-user podman-leantime trilium-server
curl -I http://127.0.0.1:8080
curl -I http://127.0.0.1:8081
```

n100から公開URLも確認します。

```console
curl -I https://project.sandi05.com
curl -I https://notes.sandi05.com
```

現在の`flake.lock`が固定するprivate `KeishiS/streaming` inputは、匿名HTTPSの
GitHub archiveから取得できません。n100の評価は、このinputの取得時に失敗します。
n100へ反映する前に、取得可能なURL・revisionへ更新するか、認証を必要としない配置へ
移してください。この問題はcalc-servとlenovoの評価を妨げません。

## Leantime

Leantimeはrootless Podman containerとして実行します。永続データにはPodman volumeを使用し、
MariaDBはlenovo上のsystem serviceとして実行します。

接続情報とsession secretは`secrets/leantime.env.enc`で暗号化して管理します。
平文のcredentialをNix式、Git、Nix Storeまたはcommand lineへ含めてはいけません。

MariaDBのaccountは`leantime-database-user.service`が作成します。このunitは
`LEAN_DB_PASSWORD`が16進文字列であることを確認してから、local TCP接続用accountへ反映します。

最初にlocal administratorを作成し、通常のWeb UIが動くことを確認します。自動user作成を
有効にする場合も、既定roleをadministratorにしないでください。

container設定はOIDC client IDとして`leantime`、issuerとして
`https://id.sandi05.com/oauth2/openid/leantime/`を参照します。client secretは
`leantime.env.enc`からcontainerへ渡します。Kanidm側のLeantime clientはこのリポジトリで
宣言していないため、OIDCを利用する場合はclientの存在、callback URL
`https://project.sandi05.com/oidc/callback`およびscopeを別途確認してください。

Leantime 3.9.8のOIDC clientはPKCE challengeを送らず、ID tokenはRS256だけを検証します。
loginに失敗した場合は、issuer、callback URL、client ID、時刻同期、discovery documentの
順に確認します。

## TriliumNext

TriliumNextは`services.trilium-server`で実行し、データを`/var/lib/trilium`へ保存します。
serviceはloopbackのport 8081で待ち受け、lenovoとn100のnginxを経由して
`https://notes.sandi05.com`として公開します。

最初にlocal passwordを設定し、MFAを有効にしてください。TriliumNext 0.102.2・0.103.0の
OIDC実装はKanidm 1.10.4との間で追加の互換対応が必要になるため、現在はKanidm OIDCを
使用しません。

backupはTriliumNext組み込み機能ではなく、ホスト側のbackup方針に従います。

## ネットワーク境界

LeantimeとTriliumNextのapplication portはloopbackだけで待ち受けます。LANからlenovoへ
直接到達できるのはnginxのport 80だけです。n100の公開proxy以外へ転送先を増やす場合は、
firewall、Host headerおよびTLS終端の責務を同じ変更で確認します。

現在の`lenovo.sandi05.com`はA recordだけを持つため、IPv4のfirewall ruleを使用します。
AAAA recordを追加する場合は、n100のIPv6 source addressを許可するip6tables ruleも
同時に追加してください。
