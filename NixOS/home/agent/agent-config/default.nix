{
  config,
  lib,
  pkgs,
  ...
}:
let
  codexConfig = "${config.home.homeDirectory}/.codex/config.toml";
  claudeConfig = "${config.home.homeDirectory}/.claude.json";
  codexMcpConfig = ''

    [mcp_servers.agent-services]
    url = "https://mcp.sandi05.com/mcp"
    oauth_resource = "https://mcp.sandi05.com/mcp"
    required = false
    default_tools_approval_mode = "prompt"
    startup_timeout_sec = 20
    tool_timeout_sec = 60

    [mcp_servers.agent-services.oauth]
    client_id = "toolhive-mcp"
  '';
in
{
  home.file = {
    ".codex/AGENTS.md".source = ./AGENTS.md;

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

  # Codexはdirectory trustなどをconfig.tomlへ書き込むため、Nix Storeへの
  # read-only symlinkにはしない。初回と旧symlinkからの移行時だけtemplateをコピーし、
  # 以後のCodexによる変更は保持する。
  home.activation.initializeCodexConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if [ -L ${lib.escapeShellArg codexConfig} ]; then
      ${pkgs.coreutils}/bin/rm ${lib.escapeShellArg codexConfig}
    fi

    if [ ! -e ${lib.escapeShellArg codexConfig} ]; then
      ${pkgs.coreutils}/bin/install \
        --directory \
        --mode 0700 \
        ${lib.escapeShellArg "${config.home.homeDirectory}/.codex"}
      ${pkgs.coreutils}/bin/install \
        --mode 0600 \
        ${./codex-config.toml} \
        ${lib.escapeShellArg codexConfig}
    fi

    if ! ${pkgs.gnugrep}/bin/grep -Eq \
      '^[[:space:]]*mcp_oauth_callback_port[[:space:]]*=' \
      ${lib.escapeShellArg codexConfig}; then
      {
        ${pkgs.coreutils}/bin/printf '%s\n\n' \
          'mcp_oauth_callback_port = 8765'
        ${pkgs.coreutils}/bin/cat ${lib.escapeShellArg codexConfig}
      } > ${lib.escapeShellArg "${codexConfig}.new"}
      ${pkgs.coreutils}/bin/chmod 0600 ${lib.escapeShellArg "${codexConfig}.new"}
      ${pkgs.coreutils}/bin/mv \
        ${lib.escapeShellArg "${codexConfig}.new"} \
        ${lib.escapeShellArg codexConfig}
    fi

    if ! ${pkgs.gnugrep}/bin/grep -Fq \
      '[mcp_servers.agent-services]' \
      ${lib.escapeShellArg codexConfig}; then
      ${pkgs.coreutils}/bin/printf '%s\n' \
        ${lib.escapeShellArg codexMcpConfig} \
        >> ${lib.escapeShellArg codexConfig}
    fi
  '';

  # Claude Code keeps project trust and OAuth state in ~/.claude.json, so
  # preserve the mutable file and merge only this user-scoped MCP definition.
  home.activation.initializeClaudeMcp = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    ${pkgs.coreutils}/bin/install \
      --directory \
      --mode 0700 \
      ${lib.escapeShellArg config.home.homeDirectory}

    claude_mcp="$(${pkgs.jq}/bin/jq -c . ${./claude-mcp.json})"
    if [ -e ${lib.escapeShellArg claudeConfig} ]; then
      if ! ${pkgs.jq}/bin/jq -e . ${lib.escapeShellArg claudeConfig} >/dev/null; then
        echo "invalid JSON in ${claudeConfig}; refusing to overwrite it" >&2
        exit 1
      fi
      ${pkgs.jq}/bin/jq \
        --argjson server "$claude_mcp" \
        '.mcpServers["agent-services"] = $server' \
        ${lib.escapeShellArg claudeConfig} \
        > ${lib.escapeShellArg "${claudeConfig}.new"}
    else
      ${pkgs.jq}/bin/jq \
        --null-input \
        --argjson server "$claude_mcp" \
        '{mcpServers: {"agent-services": $server}}' \
        > ${lib.escapeShellArg "${claudeConfig}.new"}
    fi

    ${pkgs.coreutils}/bin/chmod 0600 ${lib.escapeShellArg "${claudeConfig}.new"}
    ${pkgs.coreutils}/bin/mv \
      ${lib.escapeShellArg "${claudeConfig}.new"} \
      ${lib.escapeShellArg claudeConfig}
  '';
}
