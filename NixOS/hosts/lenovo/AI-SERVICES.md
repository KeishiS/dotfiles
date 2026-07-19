# AI service integration の導入手順

この host では、Leantime、MariaDB、TriliumNext、および ToolHive 用の
rootless Podman API を動かす。稼働データは内蔵 NVMe の `/var/lib` 以下に置き、
`/storage` と `/users` は使用しない。backup は issue 010 の対象外である。

## 反映順序

最初に Cloudflare で次の record を n100 と同じ公開 address へ向ける。

- `project.sandi05.com`
- `notes.sandi05.com`
- `mcp.sandi05.com`

次に各 host で、設定を一時反映して状態を確認する。

```bash
# calc-serv: Kanidm OIDC clients（Leantime・ToolHive）
sudo nixos-rebuild test --flake .#nixos-sandi-calc-serv

# lenovo: MariaDB, Leantime, TriliumNext, rootless Podman
sudo nixos-rebuild test --flake .#nixos-sandi-lenovo

# n100: TLS reverse proxy
sudo nixos-rebuild test --flake .#nixos-sandi-n100
```

問題がなければ、同じ順序で `test` を `switch` に変えて永続化する。

現在の `flake.lock` が固定する private `KeishiS/streaming` input は、匿名 HTTPS の
GitHub archive から取得できない。n100 の通常の評価は、本構成へ到達する前にこの
既存 input の取得で失敗する。n100 へ反映する前に、取得可能な URL・revision へ
`streaming` input を更新するか、認証を必要としない配置へ移すこと。Issue 010 の
nginx 構成自体は、同じ option を持つ local stub で置換したフルビルドに成功している。
この問題は calc-serv と lenovo の反映を妨げない。

## 基盤の確認

lenovo で次を確認する。

```bash
getent passwd 955 956
systemctl status mysql leantime-database-user podman-leantime trilium-server
systemctl status toolhive-podman
sudo -u leantime podman ps
sudo ss -lntp
curl -fsS -H 'Host: project.sandi05.com' http://127.0.0.1/
curl -fsS -H 'Host: notes.sandi05.com' http://127.0.0.1/
```

反映前の`getent`で、UID 955・956が意図しない既存accountに割り当てられていない
ことを確認する。反映後はそれぞれ`leantime`・`toolhive`になっていることを確認する。

`8080` と `8081` は loopback だけから利用し、LAN から直接公開しない。
lenovo の port 80 は n100 (`192.168.100.31`) からだけ firewall で許可する。
現在の`lenovo.sandi05.com`はA recordだけを持つためIPv4 ruleで十分である。AAAA record
を追加する場合は、n100のIPv6 source addressを許可するip6tables ruleも同時に追加する。

n100 では次を確認する。

```bash
curl -I https://project.sandi05.com
curl -I https://notes.sandi05.com
curl -I https://mcp.sandi05.com
```

credential が未配置ならvMCPは起動せず、`mcp.sandi05.com`は`502`になる。起動後も
公開するのは`/mcp`とRFC 9728 discovery pathだけで、その他のpathは`404`になる。

## 初期設定と OIDC

Leantime では最初に local administrator を作成し、通常の Web UI が動くことを確認
する。Kanidm login は `leantime` client を使用し、callback は
`https://project.sandi05.com/oidc/callback` である。自動 user 作成を有効にする場合も、
既定 role を administrator にしない。

TriliumNext はlocal passwordとMFAで保護する。0.102.2・0.103.0のOIDC実装はKanidm
1.10.4との間でtoken endpoint認証方式とID token署名方式の明示が必要となり、配布済み
bundleへのlocal patchを継続保守する複雑性に見合わないため、Kanidm OIDCは使用しない。

Leantime 3.9.8 の OIDC client は PKCE challenge を送らず、ID token は RS256 だけを
検証できる。このため Kanidm の `leantime` client に限りPKCE必須化を解除し、legacy
crypto（RS256）を有効にしている。ToolHiveにはこの例外を適用しない。
login に失敗した場合は issuer、callback、client ID、時刻同期、discovery document
の順に確認する。

## ToolHive credentialの配置

ToolHive の管理用 Podman socket は `/run/toolhive/podman.sock` にあり、
`toolhive` user だけが使用する。この socket、`/var/lib/toolhive`、upstream token を
calc-serv や `agent-sandbox` へ共有してはならない。

tokenをcommand line引数、shell history、chatへ貼り付けない。TriliumNextのAI専用
ETAPI tokenは次のsops-nix binary secretとして暗号化管理する。

```text
hosts/lenovo/secrets/triliumnext-etapi-token.enc
```

復号後のfileはsops-nixが`root:root`、mode `0400`で`/run/secrets`へ配置する。
`toolhive-triliumnext`だけがsystemd credentialとして受け取り、secret更新時は
connectorとvMCPを自動再起動する。平文fileをrepositoryや`/var/lib/toolhive`へ
配置しない。

Leantimeの公式MCP pluginを導入してAI専用API keyまたはPATを作成した後、同様に配置する。

```bash
read -rsp 'Leantime API token: ' token
printf '%s' "$token" |
  sudo install -m 0440 -o root -g toolhive /dev/stdin \
    /var/lib/toolhive/credentials/leantime-api-token
unset token
echo
```

Leantime connectorはread tool名のallowlistが空なら起動しない。購入したpluginの
`tools/list`を確認し、読み取り専用であることを確認したtoolだけを一行に一つ記録する。

```bash
sudo install -m 0640 -o root -g toolhive /dev/stdin \
  /var/lib/toolhive/config/leantime-read-tools
```

標準入力へtool名を入力して`Ctrl-D`で終了する。`delete`、user管理、設定変更、一括更新
toolを含めない。その後に起動する。

```bash
sudo systemctl restart toolhive-leantime toolhive-vmcp
```

ToolHiveはsystemd credentialからtokenを読み、connector containerへenvironment
secretとして渡す。Leantime bridgeにはupstreamが対応する`LEANTIME_API_TOKEN`として
渡すため、token値はprocessのcommand line、ToolHiveのRunConfig、systemd unit、
Nix Storeには入らない。

## AgentからのOAuth login

第二homeへHome Manager設定を反映すると、CodexとClaudeに
`https://mcp.sandi05.com/mcp`がuser共通MCPとして追加される。

```bash
home-manager switch --flake .#agent-sandbox -b backup
codex mcp login agent-services --scopes openid,profile,email
```

Claude Codeでは起動後に`/mcp`を開き、`agent-services`を認証する。Claudeは
`toolhive-mcp` clientと固定callback `http://localhost:8765/callback`を使用する。
Codexも同じpublic client、PKCE、固定port 8765を使用する。

SSH先のcalc-servでagentを動かし、browserを手元の端末で開く場合は、最初からcallback
portをforwardして接続する。

```bash
ssh -L 8765:127.0.0.1:8765 calc-serv
```

Claudeでredirect後に接続エラーとなった場合は、Claude Codeが表示するpromptへ
browserのaddress barに残ったcallback URL全体を貼り付ける方法も利用できる。

第二homeへ保存されるのはToolHive用OAuth tokenだけである。このtokenはupstreamの
ETAPI tokenやLeantime API keyではなく、Kanidm側でuser単位に失効できる。

## 残る導入作業

公開を完了するには、次が別途必要である。

1. TriliumNext で AI 専用 ETAPI token を作る。
2. Leantime の公式 MCP plugin 1.1.0 を購入・導入し、AI 専用 API key または PAT を作る。
3. 上記手順でcredentialとLeantime read tool allowlistを配置する。
4. connector、vMCP、Kanidm OAuth、audit logを実機確認する。

候補の TriliumNext connector は
`tan-yong-sheng/triliumnext-mcp` である。read-only mode を持ち、初期 read tool を
小さくできる一方、upstream 自身が prototype と明記している。このため、導入前に
source review と実データを使わない試験を行い、問題があれば
`perfectra1n/triliumnext-mcp` などを再比較する。

固定imageはrevision `1af5b220aba23632f3034765f9fde1ab6d228b8e`（0.3.17）に対応し、
指定した`search_notes`、`get_note`、`resolve_note_id`、`read_attributes`が同revision
に存在することを確認済みである。vMCPのincoming OIDC issuerは
`https://id.sandi05.com/oauth2/openid/toolhive-mcp`とし、末尾に`/`を付けない。

agentに渡すのはKanidmが発行するvMCP用access tokenだけとし、ETAPI token、
Leantime API credential、Podman socket、ToolHive 管理 API は渡さない。
