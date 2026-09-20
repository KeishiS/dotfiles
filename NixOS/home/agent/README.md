# Agent home

AIエージェントの活用を前提としたユーザー環境

## 管理対象

このflakeは通常ホームと隔離ホームに対応する二つのHome Manager設定を提供する。

```text
homeConfigurations.agent
homeConfigurations.sandbox
```

`#agent`は通常ホーム`/users/agent`を管理します。`#sandbox`は、ホストと隔離環境の
両方で`/sandbox/by-uid/<uid>`をホームとして管理します。`<uid>`は起動ユーザーの数値UIDです。
固定パス`/home/agent`は使用しません。これにより、プロファイルを削除から保護する参照
（GC root）をホストのNix daemonからも同じパスで辿れます。

## 初回適用

通常ホーム側のcheckoutから`#agent`を適用する。

```console
home-manager switch --flake /path/to/NixOS/home/agent#agent
```

隔離ホームは`agent-sandbox`の起動時にroot権限で作成される。対象workspaceから
隔離環境へ入り、同じcheckoutの`#sandbox`を適用する。

```console
agent-sandbox
agent-home-switch /workspace/NixOS/home/agent
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

## 共有ホームへの適用

隔離ホームには、ホストが提供する`agent-home-switch FLAKE_DIRECTORY`で設定を適用します。
プロファイルが壊れていても、`/run/current-system/sw/bin/agent-home-switch`から起動できます。
このコマンドは同じUIDで共有するロックを取得し、ビルドから適用完了まで保持します。
複数のsandboxから実行した場合、後から実行した処理は先行処理の終了を待ちます。

`#sandbox`の評価には`AGENT_SANDBOX_HOME`が必要です。適用コマンドが実UIDと
`HOME`を照合して値を設定し、`--impure`でHome Managerに渡します。通常ホームの
`#agent`は従来どおり環境変数なしで評価できます。

隔離ホームでは`home-manager switch`や世代の`activate`を直接実行しないでください。
それらの操作や`nix-env`・`nix profile`の直接操作は、この共有ロックの対象外です。

## 旧ホームパスからの移行

この移行では同じホームの実体を使い続けるため、認証情報や履歴を初期化しません。
ただし、移行後の生成物は古いsandboxから利用できません。次の順序で移行します。

1. 同じUIDで起動したすべてのsandboxと、その中のエージェントを終了します。
2. ホストでこのリポジトリのNixOS設定を適用し、新しい`agent-sandbox`と`agent-home-switch`を導入します。
3. 新しいsandboxに入り、以下を実行します。

    ```console
    /run/current-system/sw/bin/agent-home-switch --migrate /workspace/NixOS/home/agent
    ```

    移行前のシェル設定が古いパスを参照して警告を出す場合でも、上記の絶対パスで実行できます。
    起動設定がシェルを終了させる場合は、ホスト側で該当する設定を退避してから再試行します。

4. sandboxを終了して入り直し、`echo "$HOME"`、`readlink -e ~/.nix-profile`、
   `command -v node gh starship`を確認します。

移行コマンドは既存のユーザープロファイルとHome Managerの世代を調べ、Store内に残る
世代のGC rootを新しい絶対パスで登録し直します。消失済みの過去世代は復元せず、
リンクを調査用に残します。現行世代が消失している場合は、その入口を
`$XDG_STATE_HOME/agent-home-migration.*`へ退避して新しい設定を構築します。
`~/.nix-profile`の旧リンク先は`$XDG_STATE_HOME/agent-nix-profile-before-migration.txt`へ保存します。
失敗時は原因を解消して同じ移行コマンドを再実行できます。

Home Managerが管理するファイルは再生成します。ツールが独自に保存した設定中の
`/home/agent`や、そのパスを指す手動作成のリンクは一括置換しません。該当ツールで
エラーが出た場合は保存先設定を変更してください。古いホームパスを含む世代の
`activate`を直接実行してロールバックすることはできません。

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
内容を確認してから退避または削除し、`agent-home-switch`を再実行します。

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
`agent-home-switch`で復旧する前に次の情報を保存する。復旧を先に行うと、シンボリックリンクや
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
| `read-pdf` | PDFのテキスト抽出、OCR、ページ画像との照合 |

PDF用ツールは通常のホーム環境にインストールせず、専用のNix環境で使用します。
`#sandbox`は`agent-config/pdf-env/`の定義と`flake.lock`だけを
`~/.config/agent/pdf-env/`へ配備します。次のコマンドで、固定したバージョンの
`poppler-utils`、`ocrmypdf`、`tesseract`を必要なときに利用できます。

```console
nix develop --no-update-lock-file "path:$(readlink -f "$HOME/.config/agent/pdf-env")" -c pdfinfo document.pdf
nix develop --no-update-lock-file "path:$(readlink -f "$HOME/.config/agent/pdf-env")" -c tesseract --list-langs
```

初回は必要なパッケージを取得・ビルドします。終了後は通常環境の`PATH`に残りませんが、
取得したパッケージはNix Storeにキャッシュされます。OCR用データは英語、日本語、
文字の向きを検出するための`osd`です。言語の追加は`agent-config/pdf-env/flake.nix`の
`enableLanguages`で行います。バージョンは専用の`flake.lock`で独立して管理します。
更新する場合はリポジトリ内の`agent-config/pdf-env/`で`nix flake update`を実行し、
PDF処理を検証してから`#sandbox`を再適用します。

配備先はシンボリックリンクなので、`readlink -f`で実体のパスを解決し、
`path:`を付けてNixに渡します。

日本語の文体や検証など、作業全般に適用する指示は`AGENTS.md`で管理します。
リモート名、Issueの運用、Git worktreeの使用可否は対象リポジトリの指示に従います。
共通skillには、複数のプロジェクトで繰り返し使う具体的な手順を置きます。

## コマンドの許可範囲

共通設定の自動許可は、Gitの差分・履歴・状態の確認を中心にします。
CodexではGitHubの情報取得も許可します。Gitの変更操作、Nix、Cargo、npmのコマンドは
共通の自動許可から外します。PDF用Nix環境の起動も一括許可の対象にはしません。

ビルドやテストもプロジェクト内のコードを実行するため、必要な許可は対象リポジトリで
タスク定義を確認して管理します。共通設定から外した操作を一律禁止するものではなく、
実行時の承認やsandboxの設定に従います。Codexのrulesはsandbox外での実行を制御するため、
すべての操作に確認を強制する仕組みではありません。

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
agent-home-switch /workspace/NixOS/home/agent
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
