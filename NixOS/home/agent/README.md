# Agent home

AIエージェントの活用を前提としたユーザー環境

## 管理対象

このflakeは`agent`用のHome Manager設定を一つ提供する。

```text
homeConfigurations.agent
```

Home Managerは第一ホーム`/users/agent`を通常のホームとして管理する。calc-servの
`agent-sandbox`が使用する`/sandbox/by-uid/<uid>`はHome Managerのホームとして扱わず、
`#agent`のactivationから隔離環境用ファイルだけを配備する。

永続workdirは隔離環境内で`/home/agent`へbind mountされる。隔離環境から見れば
`HOME=/home/agent`だが、独立したHome Manager profileは持たない。

## 初回適用

永続workdirは`agent-sandbox`の起動時にroot権限で作成される。初回のHome Manager適用
より先に、対象workspaceから一度起動して終了する。

```console
agent-sandbox
exit
```

その後、第一ホーム側のcheckoutから`#agent`を適用する。

```console
home-manager switch --flake /path/to/NixOS/home/agent#agent
```

activationは次を検査し、不一致がある場合は適用を失敗させる。

- `/sandbox`がmountpointであること
- `/sandbox/by-uid/<uid>`がsymlinkではないdirectoryであること
- 所有者が適用ユーザーのUIDとGIDであること
- modeが`0700`であること

## 分離モデル

`agent-sandbox`の目的は、普段使用する環境とAIエージェント用の環境を分離することである。
第一ホームのSSH鍵、GPG agent、Git global configおよびその他のcredentialは隔離環境へ
公開しない。

永続workdirは同じユーザーの複数プロジェクトで共有する。Codex・Claude Codeの設定、
session、skillsおよびMCP OAuth credentialがプロジェクト間で共有されることは意図した
設計である。この境界は第一ホームへの影響を抑えるが、プロジェクト間の機密性は保証しない。

## 配備ファイル

`#agent`のactivationは、永続workdirへ次のファイルをNix Storeへのread-only symlink
として配備する。

```text
.bash_profile
.bashrc
.profile
.vimrc
.config/sheldon/plugins.toml
.config/starship.toml
.config/tmux/tmux.conf
.config/zellij/config.kdl
.codex/AGENTS.md
.codex/agent-sandbox.config.toml
.claude/CLAUDE.md
.claude/settings.json
.agents/skills
.claude/skills
.local/bin/codex
```

第一ホーム用のGit設定とcredentialは配備しない。既存の通常ファイルやdirectoryと
配備先が競合する場合は、初回だけ`.pre-agent-home-manager`を末尾に付けて退避する。

管理対象の一覧は次に保存する。

```text
~/.local/state/agent-sandbox/managed-files
```

この`~`はHome Managerを適用する第一ホーム`/users/agent`を指す。manifestは隔離環境へ
公開しない。

リポジトリから管理対象を削除した場合、activationは旧manifestに記録されたsymlink
だけを削除する。通常ファイル、credential、sessionおよび履歴は削除しない。

## パッケージ管理

隔離環境には独立したHome Manager package profileを作成しない。プロジェクトごとに
必要なコマンドは、各プロジェクトの`flake.nix`が提供する開発環境へ含める。

```console
nix develop
```

Codex本体もPATH上に必要である。永続workdirの`.local/bin/codex`はCodex本体ではなく、
PATH上の実体へ`--profile agent-sandbox`を付けて起動するwrapperである。

## Codex設定

Codex設定は、可変設定とリポジトリ管理設定に分離する。

```text
~/.codex/config.toml
~/.codex/agent-sandbox.config.toml
```

`config.toml`はCodexがdirectory trustなどを追記する通常ファイルである。
`agent-sandbox.config.toml`は
`agent-config/codex-config.toml`を参照するread-only symlinkである。

wrapperは次と同等の起動を行う。

```console
codex --profile agent-sandbox
```

profileは`config.toml`の上に重ねて読み込まれるため、同じキーが両方に存在する場合は
リポジトリ管理設定が優先される。

旧構成から初めて移行する際は、既存の`config.toml`を次へ退避し、空の書き込み可能な
`config.toml`をmode `0600`で作成する。

```text
~/.codex/config.toml.pre-profile
```

旧ファイルに保存されていたdirectory trustは新しい`config.toml`へ自動移行しない。
必要なworkspaceは移行後に再度trustする。退避ファイルは確認が終わるまで削除しない。

Codexのprofileと`AGENTS.md`は新しいprocessで読み込まれるため、`#agent`適用後は既存の
Codexを終了して新しいsessionを開始する。

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

| skill | 用途 |
| --- | --- |
| `read-pdf` | PDFのtext抽出とページ画像の照合に基づいて内容を調査する |
| `submit-trilium-idea` | アイデアを規定のMarkdown形式でTriliumNextへ保存する |

`submit-trilium-idea`は`agent-services` MCPを使用し、`Idea Inbox`配下へ
`type=code`、`mime=text/markdown`のnoteを作成する。ETAPI tokenやOAuth tokenなどの
秘密情報をnoteへ保存しない。

明示的にskillを指定する場合の例:

```text
$submit-trilium-idea を使って、このアイデアをIdea Inboxへ保存してください。
```

## 設定変更

第一ホーム側のcheckoutを編集する。

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
shell/
vim/
zellij/
```

変更後は同じcheckoutから`#agent`を再適用する。

```console
home-manager switch --flake /path/to/NixOS/home/agent#agent
```

永続workdir内にdotfilesの別checkoutを作成する必要はない。

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

Codexの同時稼働数と入れ子の上限は
`~/.codex/agent-sandbox.config.toml`で設定する。

```toml
[agents]
max_threads = 4
max_depth = 1
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
