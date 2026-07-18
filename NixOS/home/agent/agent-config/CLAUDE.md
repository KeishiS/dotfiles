@~/.codex/AGENTS.md

# Claude Code instructions

上記のファイルに coding agent 間で共有する指示を定義している。
Claude Code は、そこに記載されたサブエージェントと Git worktree の運用方針に従う。

- 親セッションを含む同時稼働数を最大4とし、サブエージェントを入れ子にしない。
