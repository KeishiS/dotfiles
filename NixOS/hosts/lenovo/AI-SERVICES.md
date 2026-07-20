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
rootless Podmanとaardvark-dnsがsystemd user scopeを利用できるよう、`toolhive` userは
lingerを有効にし、Podman serviceを`user@956.service`の起動後に開始する。Podman
serviceでは`ProtectHome`が`/run/user`も隠してrootless runtimeを破壊するため無効に
する。他のToolHive unitでは有効なままとし、user runtimeのmode `0700`と通常のUnix
権限により他userのruntime stateへのアクセスを防ぐ。

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
`https://mcp.sandi05.com/mcp`がuser共通MCPとして追加される。初回の
`agent-sandbox`内にはstandaloneの`home-manager`やzshはまだないため、
Home Managerは`nix run`で起動する。

```bash
nix run github:nix-community/home-manager/release-26.05 -- \
  switch \
  -b backup \
  --flake /workspace/NixOS/home/agent#agent-sandbox
```

適用後はsandboxを一度終了して、同じworkspaceから入り直す。

```bash
exit
agent-sandbox
codex mcp login agent-services --scopes openid
```

Claude Codeでは起動後に`/mcp`を開き、`agent-services`を認証する。Claudeは
`toolhive-mcp` clientと固定callback `http://localhost:8765/callback`を使用する。
Codexも同じpublic client、PKCE、固定port 8765を使用する。
このclientが要求するscopeは、OIDCで安定したユーザー識別子`sub`を得るための
`openid`だけとする。`profile`と`email`は認可に使用しないため要求しない。

SSH先のcalc-servでagentを動かし、browserを手元の端末で開く場合は、最初からcallback
portをforwardして接続する。

```bash
ssh -L 8765:127.0.0.1:8765 calc-serv
```

第二homeへ保存されるのはToolHive用OAuth tokenだけである。このtokenはupstreamの
ETAPI tokenやLeantime API keyではなく、Kanidm側でuser単位に失効できる。Codexの
credential fileとClaudeのmutable設定fileはmode 0600、第二homeはagent専用とする。

## TriliumNextへのアイデア送信

`NixOS/home/agent/agent-config/skills/submit-trilium-idea`をCodexとClaude Codeの
共通skillとして配布する。ユーザーがTriliumNextへの保存を依頼した場合、skillは
`Idea Inbox`を解決し、次の形式でnoteを作成する。

| 項目 | 値 |
| --- | --- |
| note type | `code` |
| MIME type | `text/markdown` |
| 親note | `Idea Inbox` |
| label | `idea` |
| label value | `status=inbox`、`source=mcp` |

Markdown本文は「概要」「背景・課題」「提案」「期待する効果」「懸念・未決事項」
「次のアクション」の順とする。note titleはTriliumNextのtitle fieldへ保存し、本文に
同じH1を重複させない。情報がない節を推測で補わず、「未記入」または未決事項として
明示する。

送信にはprefix後の`triliumnext_resolve_note_id`、`triliumnext_create_note`、
`triliumnext_read_attributes`、`triliumnext_manage_attributes`を使用する。
既存noteを更新する場合は、先に`triliumnext_get_note`で現在の本文を取得してから
`triliumnext_update_note`を呼び、無関係な内容を保持する。途中で失敗した再実行では、
作成済みnote IDを確認して属性だけを補い、同じnoteを重複作成しない。

skillはclient側の形式・手順を統一するものであり、security boundaryではない。
実際のtool制限はvMCPのCedar allowlistで強制する。`delete_note`は公開せず、ETAPI
token、OAuth token、passwordなどの秘密情報をnote本文やattributeへ保存しない。

## 残る導入作業

TriliumNext、vMCP、Kanidm OAuth、Codex、Claudeの接続は完了している。残作業は
Leantime MCP連携を扱うissue 011と、両serviceのbackup・restoreを扱う別issueへ
分離する。

候補の TriliumNext connector は
`tan-yong-sheng/triliumnext-mcp` である。permission classでreadとwriteを切り替え
られる一方、write classは作成・更新・削除を分離できず、upstream自身もprototypeと
明記している。このため、固定revisionのsource reviewとCedar tool allowlistを維持し、
問題があれば
`perfectra1n/triliumnext-mcp` などを再比較する。

固定imageはrevision `1af5b220aba23632f3034765f9fde1ab6d228b8e`（0.3.17）に対応する。
connectorのWRITE permissionは作成・更新・削除・属性変更を一括して有効化するため、
vMCPのCedar policyで`list_children_notes`、`search_notes`、`get_note`、
`resolve_note_id`、`read_attributes`、`create_note`、`update_note`、
`manage_attributes`だけを許可する。`delete_note`は一覧にも表示せず、呼び出しも
拒否する。
ToolHive自身はdigest形式のregistry pullを扱えない
ため、`toolhive-triliumnext-image`がrootless Podmanへdigest固定で事前pullし、
`localhost/triliumnext-mcp:0.3.17`を付けてからconnectorへ渡す。`latest`は使用しない。
vMCPのincoming OIDC issuerは
`https://id.sandi05.com/oauth2/openid/toolhive-mcp`とし、末尾に`/`を付けない。
lenovoではsplit DNSによりこのissuerがLAN内addressへ解決されるため、
`jwksAllowPrivateIp`は有効にする。このflagはToolHiveのOIDC validator全体に作用する
ため、issuerは固定した信頼済みKanidm以外へ変更しない。一般のoutbound URL検証は
緩和しない。
ToolHiveのCedar authorizationではtool実行actionを`Action::"call_tool"`と記述する。
`tools/list`は独立した許可対象ではなく、`call_tool`を許可されたtoolだけが一覧へ
残るresponse filtering方式である。ToolHive 0.26.1のfilter不具合を避けるため、
TriliumNextのtool境界はprefix後のCedar `Tool` resource allowlistで強制する。
Kanidmで`toolhive-mcp`を利用できるのは`ai-agent-users` groupだけとする。

agentに渡すのはKanidmが発行するvMCP用access tokenだけとし、ETAPI token、
Leantime API credential、Podman socket、ToolHive 管理 API は渡さない。
