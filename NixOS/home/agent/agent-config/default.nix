{
  config,
  lib,
  pkgs,
  ...
}:
let
  agentServicesConsumers = import ../agent-services-consumers.nix;
  codexConsumer = agentServicesConsumers.codex;
  claudeConsumer = agentServicesConsumers.claude-code;
  codexConfig = "${config.home.homeDirectory}/.codex/config.toml";
  claudeConfig = "${config.home.homeDirectory}/.claude.json";
  codexMcpConfig = ''
    [mcp_servers.agent-services]
    url = "${codexConsumer.endpoint}"
    oauth_resource = "${codexConsumer.endpoint}"
    required = false
    default_tools_approval_mode = "prompt"
    startup_timeout_sec = 20
    tool_timeout_sec = 60

    [mcp_servers.agent-services.oauth]
    client_id = "${codexConsumer.oauthClientId}"
  '';
  codexMcpConfigFile = pkgs.writeText "codex-agent-services.toml" codexMcpConfig;
  claudeMcpConfig = builtins.toJSON {
    type = "http";
    url = claudeConsumer.endpoint;
    oauth = {
      clientId = claudeConsumer.oauthClientId;
      callbackPort = claudeConsumer.callbackPort;
      authServerMetadataUrl = "${claudeConsumer.issuer}/.well-known/oauth-authorization-server";
      scopes = builtins.concatStringsSep " " claudeConsumer.scopes;
    };
  };
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

    # agent-sandbox intentionally has no desktop keyring or D-Bus session.
    # Keep MCP OAuth tokens in the persistent, mode-0700 second home instead.
    ${pkgs.gawk}/bin/awk \
      '
        BEGIN {
          print "mcp_oauth_callback_port = 8765"
          print "mcp_oauth_credentials_store = \"file\""
          print ""
        }
        /^[[:space:]]*mcp_oauth_callback_port[[:space:]]*=/ { next }
        /^[[:space:]]*mcp_oauth_credentials_store[[:space:]]*=/ { next }
        { print }
      ' \
      ${lib.escapeShellArg codexConfig} \
      > ${lib.escapeShellArg "${codexConfig}.new"}
    ${pkgs.coreutils}/bin/chmod 0600 ${lib.escapeShellArg "${codexConfig}.new"}
    ${pkgs.coreutils}/bin/mv \
      ${lib.escapeShellArg "${codexConfig}.new"} \
      ${lib.escapeShellArg codexConfig}

    ${pkgs.gawk}/bin/awk \
      -v managed_block=${lib.escapeShellArg codexMcpConfigFile} \
      '
        function print_managed_block(    line) {
          while ((getline line < managed_block) > 0) print line
          close(managed_block)
          inserted = 1
        }

        /^\[mcp_servers\.agent-services(\.|\])/ {
          if (!inserted) print_managed_block()
          skipping = 1
          next
        }

        /^\[/ { skipping = 0 }
        !skipping { print }

        END {
          if (!inserted) {
            print ""
            print_managed_block()
          }
        }
      ' \
      ${lib.escapeShellArg codexConfig} \
      > ${lib.escapeShellArg "${codexConfig}.new"}
    ${pkgs.coreutils}/bin/chmod 0600 ${lib.escapeShellArg "${codexConfig}.new"}
    ${pkgs.coreutils}/bin/mv \
      ${lib.escapeShellArg "${codexConfig}.new"} \
      ${lib.escapeShellArg codexConfig}
  '';

  # Claude Code keeps project trust and OAuth state in ~/.claude.json, so
  # preserve the mutable file and merge only this user-scoped MCP definition.
  home.activation.initializeClaudeMcp = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    ${pkgs.coreutils}/bin/install \
      --directory \
      --mode 0700 \
      ${lib.escapeShellArg config.home.homeDirectory}

    claude_mcp=${lib.escapeShellArg claudeMcpConfig}
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
