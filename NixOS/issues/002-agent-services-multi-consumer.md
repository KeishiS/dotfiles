# agent-servicesを複数のMCP consumerから安全に利用できるようにする

## 背景

ToolHive vMCPが公開する`agent-services`は、移行前はCodexとClaude Codeから
`https://mcp.sandi05.com/mcp`を通じて利用している。OAuth clientは
`toolhive-mcp`を共有し、localhostの固定callbackを使用している。

今後はChatGPTをはじめとするbrowser・hosted serviceや、Device Flowを利用する
headless clientからも同じToolHive workload群を利用したい。

Kanidmでは異なるapplication間でOAuth clientを共有しないことが推奨される。
また、現在のToolHive vMCP設定はissuer、client ID、audienceおよびresourceを
単一のOAuth clientへ固定している。そのため、接続元ごとに認証境界を分離しつつ、
共通のToolHive workload群を再利用できる構成へ移行する。

## 目的

- MCP consumerごとにOAuth client、issuer、audience、resourceおよびredirect URIを分離する。
- consumer単位で認可、失効、監査、停止および移行を実施できるようにする。
- TriliumNextとLeantimeのconnectorは共有し、同じ定義を重複して起動しない。
- consumer定義を唯一のsource of truthとし、関連hostとclientの設定を導出する。
- 将来のconsumer、refresh token、CIMD、DCRおよびDevice Flowを追加できる構造にする。

## 命名規則

consumer識別子には英小文字のhyphen-caseを使用する。

| 対象 | 命名規則 | 例 |
| --- | --- | --- |
| OAuth client ID | `agent-services-<consumer>` | `agent-services-codex` |
| vMCP service | `toolhive-vmcp-<consumer>` | `toolhive-vmcp-codex` |
| vMCP設定 | Nixによる生成物 | `agent-services-codex-vmcp.yaml` |
| 外部path | `/<consumer>/mcp` | `/codex/mcp` |
| resource | `https://mcp.sandi05.com/<consumer>/mcp` | `https://mcp.sandi05.com/codex/mcp` |
| audit component | `agent-services-<consumer>-vmcp` | `agent-services-codex-vmcp` |

初期consumerは次の3つとする。

- `codex`
- `claude-code`
- `chatgpt`

## 設計

### 共通部分

以下はconsumer間で共有する。

- ToolHiveの`agent-services` group
- TriliumNext connector
- Leantime connector
- connectorへ渡すupstream credential
- tool nameのprefix規則
- Cedar policyの基本allowlist

### consumer固有部分

以下はconsumerごとに分離する。

- Kanidm OAuth client
- OAuth client種別とtoken endpoint認証方式
- redirect URI
- issuer、client ID、audience、resourceおよびscope
- ToolHive vMCP processとlisten port
- protected-resource metadata
- nginx location
- Cedar policyの追加制限
- audit componentとjournal
- client側のMCP設定

### consumer定義

consumer情報を複数hostから参照できる共通Nixデータとして定義する。
秘密情報やhost固有packageをこの定義へ含めない。

概念上、各consumerは少なくとも次の属性を持つ。

```nix
{
  oauthClientId = "agent-services-codex";
  hostname = "mcp.sandi05.com";
  basePath = "/codex";
  endpoint = "https://mcp.sandi05.com/codex/mcp";
  callbackUrls = [ "http://localhost:8765/callback" ];
  callbackPort = 8765;
  public = true;
  scopes = [ "openid" ];
  vmcpPort = 4484;
}
```

共通定義は独立したHome Manager Flakeからも参照できるよう、
`home/agent/agent-services-consumers.nix`へ置く。NixOS host側がこの定義を参照し、
独立Flakeから親directoryを参照しない。

consumerごとにsubdomainを増やす構成は、DNS recordとACME SANを追加する外部作業が
必要になるため採用しない。既存の`mcp.sandi05.com`でpathを分離する。

## 実装計画

### 1. 現行構成の検証と移行条件の固定

- 現在の`toolhive-mcp`について、公開metadata、issuer、audience、scopeを記録する。
- CodexとClaude Codeのcallback、OAuth credential保存先、token claimを確認する。
- 既存endpointのMCP initialize、tools/listおよび代表的なread-only toolを確認する。
- 現在使用しているport、hostname、systemd unit名と競合しない割当を決める。
- 破壊的な一括移行とし、旧構成との併存期間を設けない。

#### Baseline（2026-07-21）

リポジトリと公開endpointから次を確認した。

| 項目 | 現在値 |
| --- | --- |
| MCP endpoint | `https://mcp.sandi05.com/mcp` |
| protected-resource metadata | `https://mcp.sandi05.com/.well-known/oauth-protected-resource/mcp` |
| OAuth client ID | `toolhive-mcp` |
| issuer | `https://id.sandi05.com/oauth2/openid/toolhive-mcp` |
| resource | `https://mcp.sandi05.com/mcp` |
| audience | `toolhive-mcp` |
| scope | `openid` |
| callback | `http://localhost:8765/callback` |
| vMCP unit | `toolhive-vmcp.service` |
| vMCP listen address | `127.0.0.1:4483` |
| ToolHive group | `agent-services` |

`toolhive-vmcp.service`は`toolhive-triliumnext.service`と
`toolhive-leantime.service`を`wants`および`after`に持つ。connectorは共通の
`agent-services` groupへ所属する。vMCPの停止はconnectorを停止させない構造である。

外部経路はn100のnginxからlenovoのnginxを経由して`127.0.0.1:4483`へ到達する。
公開pathは`/mcp`と2つのprotected-resource metadata pathに限定され、その他は
`404`となる設定である。

2つのprotected-resource metadata endpointは同じ内容を返す。

```json
{
  "resource": "https://mcp.sandi05.com/mcp",
  "authorization_servers": [
    "https://id.sandi05.com/oauth2/openid/toolhive-mcp"
  ],
  "bearer_methods_supported": ["header"],
  "scopes_supported": ["openid"]
}
```

未認証で`/mcp`へrequestすると`401 Unauthorized`となり、次を含む
`WWW-Authenticate` headerが返る。

- realm: `https://id.sandi05.com/oauth2/openid/toolhive-mcp`
- resource metadata: `https://mcp.sandi05.com/.well-known/oauth-protected-resource/mcp`
- scope: `openid`
- error: `invalid_request`
- error description: `authorization header required`

authorization server metadataでは次を確認した。

- authorization endpoint: `https://id.sandi05.com/ui/oauth2`
- token endpoint: `https://id.sandi05.com/oauth2/token`
- response type: `code`
- PKCE: `S256`
- token endpoint認証方式: `client_secret_basic`、`client_secret_post`
- grant type: `authorization_code`、token exchange
- `refresh_token` grant、`offline_access`、CIMDおよびDCRは広告されていない。

Kanidm設定では`toolhive-mcp`をpublic clientとしている一方、公開metadataの
`token_endpoint_auth_methods_supported`に`none`がない。この差異がCodex・Claude Code
および今後のconsumerのOAuth client選択へ与える影響を、client分離前に確認する。

CodexとClaude Codeは現在同じendpoint、OAuth client ID、scopeおよびcallback portを
使用している。第二homeではCodexのOAuth credential fileとClaudeのmutable設定fileが
owner `agent:agent`、mode `0600`で存在することを確認した。credentialの内容は確認して
いないため、token claimとrefresh tokenの有無は未確認である。

次の項目は認証済みclientまたは稼働hostでの確認が必要なため未完了である。

- access tokenのissuer、audience、resource、scopeおよび有効期限
- MCP initialize、tools/listおよび代表的なread-only tool
- lenovo上のsystemd unitとlisten socketの実稼働状態
- CodexとClaude Codeの再起動後のcredential再利用
- token失効時の挙動

このbaselineは移行前の記録であり、ロールバック用の互換経路ではない。問題がある場合は
新構成を修正して再適用し、削除したclient ID、unit、endpointを復活させない。

### 2. consumer共通定義の追加

- consumer ID、OAuth client ID、hostname、resource、callback、scope、portを定義する。
- endpoint、portおよびOAuth client IDの重複をassertionで拒否する。
- callback URLはconsumerごとに明示し、暗黙の共用を行わない。
- confidential clientのsecretは共通定義へ含めない。

### 3. Kanidm OAuth clientの分離

`hosts/calc-serv/kanidm.nix`へconsumerごとのclientを追加する。

- `agent-services-codex`: public client、PKCE S256、localhost callback
- `agent-services-claude-code`: public client、PKCE S256、localhost callback
- `agent-services-chatgpt`: ChatGPTの要件に合わせた事前登録client
- login可能な主体は原則として`ai-agent-users` groupに限定する。
- legacy cryptoやPKCE無効化は行わない。
- confidential clientのsecretはsops-nixで管理し、Nix Storeへ平文を含めない。

ChatGPTの正確なcallback URLはChatGPTのapp管理画面で確認してから登録する。
Kanidmのmetadataが広告するtoken endpoint認証方式とChatGPT側の設定が一致することを
確認する。

### 4. vMCP entrypointの複数化

`hosts/lenovo/ai-services.nix`でconsumerごとにvMCP serviceを生成する。

- 各serviceは共通の`agent-services` groupを参照する。
- issuer、client ID、audience、resource、scopeおよびaudit componentを分離する。
- consumerごとに異なるlocalhost portでlistenする。
- service hardeningとsession HMAC secretの扱いは既存設定を継承する。
- connector、Podman socketおよびToolHive管理APIを外部へ公開しない。
- 一つのconsumerの停止がconnectorや他consumerを停止させない依存関係にする。

ToolHive設定の重複を抑えるため、共通templateからconsumer別YAMLを生成できるか確認する。
生成結果が読みにくい場合は共通部分を明示的に複製し、差分検証を追加する。

### 5. nginxとDNSの公開経路追加

lenovoの内部nginxとn100の外部nginxへconsumer別locationを追加する。

`mcp.sandi05.com`で公開するpathは次に限定する。

- `/<consumer>/mcp`
- `/.well-known/oauth-protected-resource/<consumer>/mcp`

その他のpathは`404`とし、HTTPはHTTPSへredirectする。ACME certificate、DNS、
proxy timeout、WebSocketまたはstreamable HTTPの要件を既存endpointと揃える。

### 6. client設定の移行

- CodexのMCP URLとclient IDを`agent-services-codex`へ変更する。
- Claude CodeのMCP URLとclient IDを`agent-services-claude-code`へ変更する。
- clientごとに再認証し、credentialが互いに上書きされないことを確認する。
- ChatGPTではDeveloper Modeからcustom MCP appを作成し、専用endpointを登録する。
- ChatGPTのcallback URLとclient secretはリポジトリへ記録しない。
- 利用可能なtoolとwrite actionの承認動作をconsumerごとに確認する。

### 7. 一括移行

後方互換性は維持せず、旧`toolhive-mcp`、`toolhive-vmcp.service`、
`https://mcp.sandi05.com/mcp`および旧client設定を新構成と同時に削除する。
適用後はCodexとClaude Codeをconsumer別clientで再認証する。

### 8. 文書化

`hosts/lenovo/AI-SERVICES.md`へ次を追記する。

- consumer追加手順
- 命名規則
- public clientとconfidential clientの選択基準
- callback URLとclient secretの取扱い
- metadata確認コマンド
- consumer単位の停止、失効および再認証手順
- ChatGPT workspaceとDeveloper Modeの設定手順

## 将来対応

以下は初期移行と分離して扱う。

- Kanidmまたは別のauthorization serverによるrefresh tokenと`offline_access`
- Client ID Metadata Documents（CIMD）
- Dynamic Client Registration（DCR）
- OAuth 2.0 Device Authorization Grant（Device Flow）
- consumerごとに異なるCedar policyを宣言するNix option
- OpenAI管理client certificateを用いたmTLS検証

Device Flowを追加する場合も、OAuth clientとtokenの失効単位はconsumerごとに分離する。

## 実装状況

2026-07-21時点で次を実装した。

- `home/agent/agent-services-consumers.nix`をconsumer定義のsource of truthとして追加
- consumer ID形式、OAuth client ID、endpointおよびportのassertion
- CodexとClaude CodeのKanidm OAuth client分離
- Kanidm provisioningのorphan cleanupによる旧shared clientの削除
- consumer別vMCP YAMLとsystemd serviceの生成
- `mcp.sandi05.com`配下のconsumer別nginx location生成
- Codexの管理対象TOML blockをHome Manager適用時に置換するmigration
- Claude Codeのmutable設定へconsumer別定義をmergeする処理
- 旧`toolhive-mcp`、旧vMCP unit、旧endpoint設定および静的vMCP YAMLの削除

ChatGPT consumerはclient ID、pathおよびportを予約しているが、ChatGPTが割り当てる
connector固有callback URLが未確定のため無効としている。ChatGPTのcustom appを作成し、
正確なcallback URLとtoken endpoint認証方式を確認した後に有効化する。

旧`toolhive-mcp`はstateへ`present = false`を残さず、provision stateから除外して
kanidm-provisionのorphan cleanupに削除させる。kanidm-provision 1.3.0は
`present = false`のentityもtracking groupへ追加しようとするため、同じrunで削除したUUIDを
再追加してreferential integrity errorになる。2026-07-21の初回反映では旧clientと新client
2件の操作自体は成功し、その後のtracking更新でこの問題が発生した。

## セキュリティ要件

- 異なるapplicationでOAuth clientを共有しない。
- OAuth client secret、access token、refresh tokenをGitやNix Storeへ平文で保存しない。
- Authorization Code flowではPKCE S256を維持する。
- Kanidm 1.10.4はrefresh tokenを発行するが、metadataに`refresh_token` grantとpublic
  clientの`none`を広告しない。この実装差を`offline_access`の追加で隠さない。
- access tokenのsignature、issuer、audience、expiration、resourceおよびscopeを検証する。
- MCP endpoint以外のToolHive APIやPodman socketを公開しない。
- write toolはconsumer側の承認に加え、Cedar allowlistでも制限する。
- consumerごとにtokenとclientを失効できる状態を維持する。

## 関連ファイル

- `hosts/calc-serv/kanidm.nix`
- `home/agent/agent-services-consumers.nix`
- `modules/services/agent-services/vmcp-config.nix`
- `hosts/lenovo/ai-services.nix`
- `hosts/lenovo/AI-SERVICES.md`
- `hosts/n100/nginx.nix`
- `home/agent/agent-config/codex-config.toml`
- `home/agent/agent-config/default.nix`

## 検証

### リポジトリ検証結果（2026-07-21）

- `home/agent#homeConfigurations.agent-sandbox.activationPackage`: build成功
- `nixos-sandi-calc-serv.config.system.build.toplevel`: build成功
- `nixos-sandi-lenovo.config.system.build.toplevel`: build成功
- `nixos-sandi-n100.config.system.build.toplevel`: `streaming` inputを同optionのlocal stubへ
  置換したbuildに成功（private input取得問題は本issue外）
- Kanidm client生成結果: `agent-services-codex`、`agent-services-claude-code`
- vMCP unit生成結果: `toolhive-vmcp-codex`、`toolhive-vmcp-claude-code`
- lenovoとn100の公開locationが一致し、consumer別MCP path、consumer別RFC 9728 path、
  rootの`404`だけを持つことを確認
- ToolHive 0.26.1の`thv vmcp validate`で両consumerの生成YAMLがvalidであることを確認
- 生成YAMLでissuer、client ID、audience、resource、audit componentがconsumerごとに
  分離され、groupRefとCedar allowlistだけが共有されることを確認
- Codexのmutable TOML migration fixtureで、旧MCP blockだけを一つの新blockへ置換し、
  model、project trust、他sectionを保持することを確認

以下のruntime項目を導入gateとして確認する。

### 初回反映結果（2026-07-21）

calc-serv、lenovo、n100へ反映後、公開経路について次を確認した。

- `/codex/mcp`と`/claude-code/mcp`はMCP用`Accept` header付き未認証requestへ`401`を返す
- 各`WWW-Authenticate`はconsumer固有realm、resource metadata、`openid` scopeを返す
- consumer別protected-resource metadataのresourceとauthorization serverが正しい
- consumer別authorization-server metadataのissuer、authorization endpoint、token endpoint、
  JWKS、PKCE S256が正しい
- 旧`/mcp`と旧`toolhive-mcp` authorization-server metadataは`404`

残るruntime gateは、認証済みtokenを使うMCP initialize、tools/list、tool call、
cross-consumer token拒否、unit独立停止、およびclient再起動後のtoken再利用である。

各consumerについて次を確認する。

- protected-resource metadataの`resource`と`authorization_servers`が正しい。
- authorization server metadataからauthorization endpoint、token endpoint、PKCE方式を取得できる。
- 未認証のMCP requestが適切な`401`と`WWW-Authenticate`を返す。
- Authorization Code + PKCEによるloginが成功する。
- 別consumer用に発行されたtokenを拒否する。
- 許可されたtoolだけがtools/listへ残る。
- read toolとwrite toolが期待したCedar policyで動作する。
- 一つのvMCP serviceを停止しても他consumerとconnectorが継続動作する。
- systemd unit、nginx設定およびNixOS configurationの評価・buildが成功する。

## リポジトリ実装の完了条件

- CodexとClaude Codeがそれぞれ専用OAuth clientとendpointを使用する。
- consumer間でOAuth credential、issuer、audienceおよびresourceを共有していない。
- 共通のToolHive workload群を各consumerから利用できる。
- consumer別の認可、監査、停止、失効および再認証手順が文書化されている。
- 旧`toolhive-mcp`と`https://mcp.sandi05.com/mcp`への依存がなくなっている。

ChatGPTはconnector固有callback URLを外部管理画面で取得しない限り安全に有効化できない。
そのため、ChatGPTの実接続はリポジトリ実装とは別の導入gateとする。callback URL取得後は
予約済みconsumerへURLを設定して有効化し、上記と同じ分離・検証条件を適用する。
