# Codexでagent-servicesのOAuthセッションを再利用できるようにする

## 背景

calc-servの`agent-sandbox`では、ToolHive vMCPが公開する
移行前は`https://mcp.sandi05.com/mcp`を、Codexの`agent-services` MCPサーバとして
利用していた。移行後のendpointは`https://mcp.sandi05.com/codex/mcp`、OAuth clientは
`agent-services-codex`である。

初回認証は次のコマンドで行う。

```console
codex mcp login agent-services --scopes openid
```

`agent-sandbox`の第二ホームはセッション間で永続化されており、OAuth credentialも
再利用できることを意図している。しかし、Codexのセッションが切れた後に
`agent-services`へ接続すると、再認証が必要になる。

## 現象

Codexの起動時に次のエラーが発生し、MCPサーバの初期化に失敗する。

```text
MCP client for `agent-services` failed to start: MCP startup failed:
handshaking with MCP server failed: Send message error Transport
[rmcp::transport::worker::WorkerTransport<
rmcp::transport::streamable_http_client::StreamableHttpClientWorker<
rmcp::transport::auth::AuthClient<
codex_rmcp_client::http_client_adapter::StreamableHttpClientAdapter>>>]
error: Auth error: OAuth authorization required, when send initialize request

MCP startup incomplete (failed: agent-services)
```

再度`codex mcp login agent-services --scopes openid`を実行すると接続できるが、
セッションが切れるたびに同じ操作が必要になる。

## 期待する動作

- 初回ログイン後のOAuth credentialが`agent-sandbox`の永続化された第二ホームへ
  安全に保存される。
- Codexの再起動後も保存済みcredentialが読み込まれる。
- access tokenが失効した場合は、可能であればrefresh tokenによって更新され、
  対話的な再認証を毎回要求しない。
- tokenをNix Store、リポジトリ、systemd unitなどへ平文で保存しない。

## 調査項目

1. `codex mcp login`がOAuth credentialを保存するファイルと、そのowner、mode、保存先を確認する。
2. `agent-sandbox`の終了後もcredentialファイルが第二ホームに残ることを確認する。
3. 次回起動時にCodexが同じ`HOME`、`XDG_CONFIG_HOME`、`XDG_DATA_HOME`から
   credentialを読み込んでいるか確認する。
4. Kanidmの`agent-services-codex` clientについて、access tokenとrefresh tokenの発行、
   有効期限、scope、public clientおよびPKCEの設定を確認する。
5. ToolHive vMCPが公開するprotected resource metadataとauthorization server metadataを確認する。
6. Codexが保存済みtokenを再利用できない条件と、refresh失敗時のログを確認する。

## 関連ファイル

- `home/agent/agent-config/codex-config.toml`
- `home/agent/agent-config/default.nix`
- `hosts/calc-serv/agent-sandbox.nix`
- `hosts/calc-serv/scripts/agent-sandbox-enter`
- `home/agent/agent-services-consumers.nix`
- `modules/services/agent-services/vmcp-config.nix`
- `hosts/lenovo/ai-services.nix`
- `hosts/lenovo/AI-SERVICES.md`

## 将来対応

ブラウザを直接開けないCLI、SSH先およびheadless環境から認証できるように、
OAuth 2.0 Device Authorization Grant（Device Flow）への対応も検討する。

実装時は次の点を調査する。

- Kanidmが公開するdevice authorization endpointとtoken endpointのmetadata
- `device_code`、`user_code`、verification URIおよびpolling intervalの扱い
- CodexとToolHiveがDevice Flowを開始・継続できるか
- Device Flowで発行されたaccess tokenとrefresh tokenの保存・更新・失効方法
- `agent-sandbox`内でverification URIとuser codeを安全に利用者へ提示する方法
- Device Flowを利用できるOAuth client、scopeおよびKanidm groupの制限

Device Flow対応は、現在のAuthorization Code + PKCEによる再認証問題を解決した後の
独立した拡張として扱う。

## 調査結果

固定しているKanidm 1.10.4はAuthorization Code交換時にaccess tokenとrefresh tokenを
発行し、refresh tokenをrotationする。既定のrefresh token有効期限は16時間である。
一方、RFC 8414/OIDC discoveryでは`refresh_token` grantとpublic client用の
`token_endpoint_auth_method=none`を広告しない。`offline_access` scopeも広告しないため、
これを要求scopeへ機械的に追加しない。

`agent-sandbox`はUIDごとの`/sandbox/by-uid/<uid>`を`/home/agent`へbind mountし、
`HOME`とXDG directoryを毎回同じ場所へ設定する。Home ManagerはCodexのmutableな
`~/.codex/config.toml`を保持し、管理対象のMCP blockだけを置換する。OAuth credentialを
Nix Storeへ生成またはコピーする処理はない。

agent-sandboxにはdesktop keyringとD-Bus sessionをbind mountしない。Codexの既定`auto`が
keyringを選択すると、`codex mcp logout`がtokenを削除できないことを実環境で確認した。
このため`mcp_oauth_credentials_store = "file"`を管理対象top-level設定として強制し、
credentialを永続化された第二homeへmode 0600で保存させる。

以上から、リポジトリ側では永続home、consumer固有client、callback、およびmutable設定の
保持を保証する。16時間以内の再起動でも再認証になる場合は、Codexが保存したcredentialの
owner・modeとrefresh応答を実機で確認する。16時間を超える再認証はKanidmの既定session
policyによる可能性があり、無検証にrefresh token有効期限だけを延長しない。

## 完了条件

- `agent-sandbox`内で一度だけ`codex mcp login agent-services --scopes openid`を実行する。
- Codexおよび`agent-sandbox`を終了して、同じユーザで再度起動する。
- 追加のブラウザ認証なしで`agent-services`のMCP handshakeが成功する。
- access token失効後の挙動を確認し、再認証が必要になる条件を文書化する。
- OAuth credentialの保存先と権限を`AI-SERVICES.md`へ記載する。

## 状況

リポジトリ側の永続home、consumer分離、mutable設定migration、buildおよびfixture検証は
完了した。残る4項目はcalc-serv、lenovo、n100へ構成を反映し、実際のOAuth credential
と経過時間を伴って確認するruntime gateである。秘密値をリポジトリへ取り込んで代替検証
してはならない。

2026-07-21に3 hostへの反映が完了し、Codex専用endpoint、issuer、resource metadata、
PKCE S256および旧endpoint削除を公開経路から確認した。残る項目はagent-sandbox内での
初回login、Codex再起動後の再利用、およびaccess token失効後のrefresh確認である。
