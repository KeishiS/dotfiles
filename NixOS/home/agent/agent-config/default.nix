{ pkgs, ... }:
let
  agent-tools-install = pkgs.writeShellApplication {
    name = "agent-tools-install";
    text = builtins.readFile ./scripts/agent-tools-install;
    runtimeInputs = with pkgs; [
      bash
      curl
      nodejs_26
      pnpm_11
    ];
  };
in
{
  home.packages = [ agent-tools-install ];
  home.file = {
    ".agents/skills" = {
      source = ./skills;
      recursive = true;
    };

    ".codex/rules/commands.rules" = {
      source = ./codex-commands.rules;
      recursive = true;
    };

    ".claude/skills" = {
      source = ./skills;
      recursive = true;
    };

    ".codex/AGENTS.md".source = ./AGENTS.md;
    ".claude/CLAUDE.md".source = ./CLAUDE.md;
    "codex-config-template.toml".source = ./codex-config.toml;
    ".claude/common.settings.json".source = ./claude-settings.json;
  };
}
