# Agent home

AIエージェントの活用を前提としたユーザー環境

## 管理対象

このflakeは通常ホームと隔離ホームに対応する二つのHome Manager設定を提供する。

```text
homeConfigurations.agent
homeConfigurations.sandbox
```

`#agent`は通常ホーム`/users/agent`を管理する。`#sandbox`は隔離環境内の
`/home/agent`を管理する。

隔離ホームの実体はホスト側の`/sandbox/by-uid/<uid>`にあり、隔離環境内では
`/home/agent`へバインドマウントされる。Home ManagerのGC rootをホスト側のNix daemonから
辿れるように、同じ実体を隔離環境内の`/sandbox/by-uid/<uid>`にもバインドマウントする。

## 初回適用

通常ホーム側のcheckoutから`#agent`を適用する。

```console
home-manager switch --flake /path/to/NixOS/home/agent#agent
```

隔離ホームは`agent-sandbox`の起動時にroot権限で作成される。対象workspaceから
隔離環境へ入り、同じcheckoutの`#sandbox`を適用する。

```console
agent-sandbox
cd /workspace/NixOS/home/agent
home-manager switch --flake .#sandbox
```

`agent-sandbox`の起動処理は次を検査し、不一致がある場合は起動を失敗させる。

- `/sandbox`がマウントポイントであること
- `/sandbox/by-uid/<uid>`がシンボリックリンクではないディレクトリであること
- 所有者が適用ユーザーのUIDとGIDであること
- パーミッションが`0700`であること

隔離環境では、Home Managerが状態ファイルの保存先を決める`XDG_STATE_HOME`を次の
ホストからも見えるパスへ設定する。

```console
XDG_STATE_HOME=/sandbox/by-uid/<uid>/.local/state
```

これにより、Home ManagerのprofileとGC rootは`XDG_STATE_HOME`の配下に作成される。
ホスト側のNix daemonもこれらのパスを辿れるため、現行世代と履歴世代が日次の
ガベージコレクションで誤って削除されることを防ぐ。

## 分離モデル

`agent-sandbox`の目的は、普段使用する環境とAIエージェント用の環境を分離することである。
第一ホームのSSH鍵、GPG agent、Git global configおよびその他のcredentialは隔離環境へ
公開しない。

永続workdirは同じユーザーの複数プロジェクトで共有する。Codex・Claude Codeの設定、
session、skillsおよびMCP OAuth credentialがプロジェクト間で共有されることは意図した
設計である。この境界は第一ホームへの影響を抑えるが、プロジェクト間の機密性は保証しない。

## 配備ファイル

`#sandbox`のactivationは、隔離ホームへ次の主なファイルをNix Storeへの読み取り専用の
シンボリックリンクとして配備する。

```text
.bash_profile
.bashrc
.profile
.vimrc
.config/starship.toml
.codex/AGENTS.md
.claude/CLAUDE.md
.agents/skills
.claude/skills
```

通常ホーム用のGit設定とcredentialは配備しない。既存ファイルが配備先と競合する場合は、
内容を確認してから退避または削除し、`home-manager switch`を再実行する。

## Claude Code設定

Claude Codeの共通指示、settingsおよびskillsはread-only symlinkとして配備する。
認証情報、session、履歴およびプロジェクト固有の設定は管理しない。

## 起動方法

`agent-sandbox`は、起動時のカレントディレクトリを読み書き可能なworkspaceとして
`/workspace`へ公開する。

```console
agent-sandbox
```

GPUが必要な場合だけ`--gpu`を指定する。

```console
agent-sandbox --gpu
```

隔離環境ではStarship promptに黄色の`[sandbox]`を表示し、対話shellにはBashを使用する。

```console
echo "${AGENT_SANDBOX:-outside}"
hostname
```

期待値:

```text
1
agent-sandbox
```

## シェル環境の異常調査

Starshipが表示されない、またはHome Managerで導入したコマンドを実行できない場合は、
`home-manager switch`で復旧する前に次の情報を保存する。復旧を先に行うと、シンボリックリンクや
`PATH`の異常が上書きされ、原因を確認できなくなる。

```console
{
  date --iso-8601=seconds
  hostname
  printf 'SHELL=%s\nPATH=%s\n' "$SHELL" "$PATH"
  type -a starship node pnpm gh home-manager
  ls -ld ~/.bashrc ~/.profile ~/.config/starship.toml ~/.nix-profile
  readlink -f ~/.bashrc
  readlink -f ~/.profile
  readlink -f ~/.nix-profile
  ls -ld ~/.local/state/nix/profiles/home-manager
  home-manager generations
} > /tmp/agent-sandbox-state.txt 2>&1
```

採取結果は次のファイルで確認する。

```console
cat /tmp/agent-sandbox-state.txt
```

隔離環境の`/tmp`はセッションごとの一時ディレクトリであり、`agent-sandbox`を終了すると削除される。
調査を別のセッションで続ける場合は、終了前に`/workspace`などの必要な場所へ採取結果を移す。

## GitHub CLI認証

Bash起動時に次のファイルが読み取り可能な場合、その内容を`GH_TOKEN`として読み込む。

```text
~/.config/gh/token
```

tokenファイル自体は管理しない。権限は`0600`に設定する。

## 共通skills

`agent-config/skills/`を次の両方へ配備する。

```text
~/.agents/skills/
~/.claude/skills/
```

現在管理するskills:

| skill      | 用途                                                    |
| ---------- | ------------------------------------------------------- |
| `read-pdf` | PDFのtext抽出とページ画像の照合に基づいて内容を調査する |

## 設定変更

通常ホーム側のcheckoutを編集する。

```console
cd /path/to/NixOS/home/agent
vim agent-config/AGENTS.md
git diff
```

主な編集対象:

```text
agent-config/AGENTS.md
agent-config/CLAUDE.md
agent-config/codex-config.toml
agent-config/claude-settings.json
agent-config/skills/
main-agent.nix
main-sandbox.nix
starship/
vim/
zellij/
```

通常ホームの設定を変更した場合は`#agent`を再適用する。

```console
home-manager switch --flake /path/to/NixOS/home/agent#agent
```

隔離ホームの設定を変更した場合は`agent-sandbox`へ入り、workspaceとして公開された
同じcheckoutから`#sandbox`を再適用する。

```console
agent-sandbox
cd /workspace/NixOS/home/agent
home-manager switch --flake .#sandbox
```

隔離ホーム内にdotfilesの別checkoutを作成する必要はない。

## Git認証

第一ホームのSSH agent、GPG agentおよびGit global configは隔離環境へ公開しない。
private repositoryを使用する場合は、隔離環境専用のHTTPS credential、SSH鍵または
Git credential helperを永続workdirへ設定する。秘密情報はこのrepositoryへcommitしない。

## サブエージェント情報の分離

永続workdirは複数projectで共有するが、session transcriptは各toolがprojectごとに
識別して保存する。

Codex:

```text
~/.codex/agents/
~/.codex/sessions/
~/.codex/archived_sessions/
```

Claude Code:

```text
~/.claude/agents/
~/.claude/projects/<project>/<session-id>.jsonl
~/.claude/projects/<project>/<session-id>/subagents/agent-<agent-id>.jsonl
```

次の場所は全projectから参照されるため、project固有の内容を置かない。

```text
~/.codex/AGENTS.md
~/.codex/agents/
~/.agents/skills/
~/.claude/CLAUDE.md
~/.claude/agents/
~/.claude/skills/
```

project固有の指示、subagentおよびskillはrepository内に置く。

```text
<repository>/AGENTS.md
<repository>/.codex/agents/
<repository>/.agents/skills/
<repository>/CLAUDE.md
<repository>/.claude/agents/
<repository>/.claude/skills/
```

## Zellijによるセッション継続

Zellijを起動してから`agent-sandbox`を使用すると、SSH切断後もsessionを継続できる。

```console
zellij --session <session-name>
cd /path/to/project
agent-sandbox
```

`Alt+o d`でdetachし、次のコマンドで再接続する。

```console
zellij attach <session-name>
```

calc-servを再起動した場合はZellij sessionも終了する。
