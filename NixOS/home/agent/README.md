# Agent home

AI エージェントの活用を前提としたユーザ環境

## Home Manager出力

このflakeは2つのHome Manager設定を提供する。

| 出力 | 配置先 | 用途 |
| --- | --- | --- |
| `agent` | `/users/agent` | calc-servのagentユーザーの第一ホーム |
| `agent-sandbox` | `/home/agent` | `agent-sandbox` 内の第二ホーム |

shell、Vim、Zellijなどの基本設定は両方へ適用する。
Codex、Claude Code、skillsの設定は `agent-sandbox` のみに適用する。

第一ホームへ適用する場合は、第一ホーム側で次を実行する。

```console
home-manager switch --flake /path/to/NixOS/home/agent#agent
```

## 第二ホーム内で Git 管理

`NixOS/home/agent` を含む dotfiles repository を第二ホーム内へクローンし
その checkout を Home Manager 設定の source of truth として使用する．

以下の操作は `agent-sandbox` 内で実行

### Repository clone

repository 全体が大きい場合は sparse checkout を使用する．

```console
mkdir -p ~/.config

nix shell nixpkgs#git -c \
  git clone --filter=blob:none --sparse \
  <repository-url> \
  ~/.config/dotfiles

cd ~/.config/dotfiles
git sparse-checkout set NixOS/home/agent
```

`<repository-url>` は実際の dotfiles repository URLへ置き換える。

### Home Managerを初回適用する

```console
nix run github:nix-community/home-manager/release-26.05 -- \
  switch \
  -b backup \
  --flake ~/.config/dotfiles/NixOS/home/agent#agent-sandbox
```

`-b backup` は、Home Manager管理前から存在する `.bashrc`、`.zshrc` などを
退避するために初回だけ指定する。すでに同名のbackupが存在する場合は、内容を確認して
別の場所へ移動してから再実行する。

適用後は一度sandboxを終了し、入り直す。

```console
exit
agent-sandbox
```

## 設定を編集する

第二ホーム内のcheckoutを直接編集する。

```console
cd ~/.config/dotfiles/NixOS/home/agent

vim agent-config/AGENTS.md
git diff
git add agent-config/AGENTS.md
git commit
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

## 変更を反映する

編集後はHome Managerを再適用する。

```console
nix run github:nix-community/home-manager/release-26.05 -- \
  switch \
  --flake ~/.config/dotfiles/NixOS/home/agent#agent-sandbox
```

`AGENTS.md`やskillを確実に再読込させるには、Home Manager適用後にCodexまたは
Claude Codeのsessionを新しく開始する。

## Repositoryを更新する

```console
cd ~/.config/dotfiles
nix shell nixpkgs#git -c git pull --ff-only

nix run github:nix-community/home-manager/release-26.05 -- \
  switch \
  --flake ~/.config/dotfiles/NixOS/home/agent#agent-sandbox
```

## Git認証

第一ホームのSSH agent、GPG agent、Git global configはsandboxへ公開されない。
private repositoryを使用する場合は、以下のいずれかを第二ホーム内で別途設定する。

- HTTPS credential
- 第二ホーム専用のSSH key
- 第二ホーム専用のGit credential helper

秘密情報はこのrepositoryへcommitしない。

## サブエージェント情報の分離

第二ホームは複数projectで共有するが、session transcriptは各toolがprojectごとに
識別して保存する。

Codex:

```text
~/.codex/agents/             user共通のカスタムagent定義
~/.codex/sessions/           session履歴
~/.codex/archived_sessions/  archive済みsession
```

Claude Code:

```text
~/.claude/agents/            user共通のカスタムagent定義
~/.claude/projects/<project>/<session-id>.jsonl
~/.claude/projects/<project>/<session-id>/subagents/agent-<agent-id>.jsonl
```

Claude Codeの `<project>` はworking directoryから生成されるため、通常はproject間で
transcriptが混在しない。Codexのsessionにもworking directoryなどのsession情報が
記録される。

一方、以下は全projectから参照されるため、project固有の内容を置かない。

```text
~/.codex/AGENTS.md
~/.codex/agents/
~/.agents/skills/
~/.claude/CLAUDE.md
~/.claude/agents/
~/.claude/skills/
```

project固有の指示、subagent、skillはrepository内に置く。

```text
<repository>/AGENTS.md
<repository>/.codex/agents/
<repository>/.agents/skills/
<repository>/CLAUDE.md
<repository>/.claude/agents/
<repository>/.claude/skills/
```

Codexは次の上限を `~/.codex/config.toml` で設定する。

```toml
[agents]
max_threads = 4
max_depth = 1
```

Claude Codeを含む共通の運用方針としても、親agentを含む同時稼働数を最大4、
subagentの入れ子を1階層までとする。

Claude Codeでsubagentの永続memoryを使用する場合は、複数projectで共有される
user scopeを避け、原則としてprojectまたはlocal scopeを選ぶ。

## Zellij でのセッション継続

zellij を起動のうえ作業することで，切断/再接続を可能とする．

### 名前付き session の起動

```console
zellij --session <session-name>
```

zellij の pane/tab で複数の作業を行うことができる．

```console
cd /path/to/project
agent-sandbox
```

### デタッチ

`Alt+o d` ででタッチできるキー設定になっている．
デタッチによって SSH 接続を閉じても zellij session が継続する．

### 再接続

```console
zellij list-sessions
# 再接続
zellij attach <session-name>
# セッションの削除
zellij kill-session <session-name>
```

calc-serv を再起動した場合は Zellij session が保持されない点を注意すること．
