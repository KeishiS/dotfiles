# Agent home

AI エージェントの活用を前提としたユーザ環境

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
  --flake ~/.config/dotfiles/NixOS/home/agent#agent
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
  --flake ~/.config/dotfiles/NixOS/home/agent#agent
```

`AGENTS.md`やskillを確実に再読込させるには、Home Manager適用後にCodexまたは
Claude Codeのsessionを新しく開始する。

## Repositoryを更新する

```console
cd ~/.config/dotfiles
nix shell nixpkgs#git -c git pull --ff-only

nix run github:nix-community/home-manager/release-26.05 -- \
  switch \
  --flake ~/.config/dotfiles/NixOS/home/agent#agent
```

## Git認証

第一ホームのSSH agent、GPG agent、Git global configはsandboxへ公開されない。
private repositoryを使用する場合は、以下のいずれかを第二ホーム内で別途設定する。

- HTTPS credential
- 第二ホーム専用のSSH key
- 第二ホーム専用のGit credential helper

秘密情報はこのrepositoryへcommitしない。

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
