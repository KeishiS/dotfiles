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
    home.shellAliases = {
        codex = "codex --profile default";
        claude = "claude --settings ~/.claude/default.settings.json";
    };
    home.packages = [ agent-tools-install ];
    home.file = {
        ".agents/skills" = {
            source = ./skills;
            recursive = true;
        };

        ".claude/skills" = {
            source = ./skills;
            recursive = true;
        };

        ".codex/AGENTS.md".source = ./AGENTS.md;
        ".claude/CLAUDE.md".source = ./CLAUDE.md;
        ".codex/default.config.toml".source = ./codex-config.toml;
        ".claude/default.settings.json".source = ./claude-settings.json;
    };
}
