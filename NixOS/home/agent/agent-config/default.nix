{
  config,
  lib,
  pkgs,
  ...
}:
let
  codexConfig = "${config.home.homeDirectory}/.codex/config.toml";
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
  '';
}
