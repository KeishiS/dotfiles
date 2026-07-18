{
  home.file = {
    ".codex/AGENTS.md".source = ./AGENTS.md;
    ".codex/config.toml".source = ./codex-config.toml;

    ".claude/CLAUDE.md".source = ./CLAUDE.md;
    ".claude/settings.json".source = ./claude-settings.json;

    ".agents/skills" = {
      source = ./skills;
      recursive = true;
    };
    ".claude/skills" = {
      source = ./skills;
      recursive = true;
    };
  };
}
