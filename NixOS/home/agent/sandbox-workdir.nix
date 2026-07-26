{
  config,
  lib,
  pkgs,
  ...
}:
let
  sandboxRoot = "/sandbox/by-uid";
  codexProfile = "agent-sandbox";
  hostStateDir = "${config.home.homeDirectory}/.local/state/agent-sandbox";

  codexWrapper = pkgs.writeShellApplication {
    name = "codex";
    runtimeInputs = [ pkgs.bash ];
    text = ''
      filtered_path=
      IFS=: read -r -a path_entries <<<"''${PATH:-}"
      for path_entry in "''${path_entries[@]}"; do
        if [ "$path_entry" = "$HOME/.local/bin" ]; then
          continue
        fi
        if [ -n "$filtered_path" ]; then
          filtered_path="$filtered_path:$path_entry"
        else
          filtered_path="$path_entry"
        fi
      done

      real_codex="$(PATH="$filtered_path" type -P codex || true)"
      if [ -z "$real_codex" ]; then
        legacy_codex="$HOME/.local/bin/codex.pre-agent-home-manager"
        if [ -x "$legacy_codex" ]; then
          real_codex="$legacy_codex"
        fi
      fi
      if [ -z "$real_codex" ]; then
        echo "codex: 実行ファイルが見つかりません。プロジェクトのflakeからCodexを導入してください。" >&2
        exit 127
      fi

      exec "$real_codex" --profile ${lib.escapeShellArg codexProfile} "$@"
    '';
  };

  vimConfig = pkgs.writeText "agent-vimrc" config.programs.vim.extraConfig;

  sandboxFiles = {
    ".agents/skills" = ./agent-config/skills;
    ".bash_profile" = "${config.home-files}/.bash_profile";
    ".bashrc" = "${config.home-files}/.bashrc";
    ".claude/CLAUDE.md" = ./agent-config/CLAUDE.md;
    ".claude/settings.json" = ./agent-config/claude-settings.json;
    ".claude/skills" = ./agent-config/skills;
    ".codex/AGENTS.md" = ./agent-config/AGENTS.md;
    ".codex/${codexProfile}.config.toml" = ./agent-config/codex-config.toml;
    ".config/sheldon/plugins.toml" = "${config.home-files}/.config/sheldon/plugins.toml";
    ".config/starship.toml" = "${config.home-files}/.config/starship.toml";
    ".config/tmux/tmux.conf" = "${config.home-files}/.config/tmux/tmux.conf";
    ".config/zellij/config.kdl" = "${config.home-files}/.config/zellij/config.kdl";
    ".local/bin/codex" = "${codexWrapper}/bin/codex";
    ".profile" = "${config.home-files}/.profile";
    ".vimrc" = vimConfig;
  };

  managedFiles = pkgs.writeText "agent-sandbox-managed-files" (
    lib.concatMapStringsSep "\n" (target: target) (lib.attrNames sandboxFiles)
    + "\n"
  );

  deployArguments = lib.concatStringsSep " \\\n" (
    lib.mapAttrsToList (
      target: source:
      "${lib.escapeShellArg target} ${lib.escapeShellArg (toString source)}"
    ) sandboxFiles
  );

  deploySandboxWorkdir = pkgs.writeShellApplication {
    name = "deploy-agent-sandbox-workdir";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.gnugrep
    ];
    text = builtins.readFile ./scripts/deploy-sandbox-workdir;
  };
in
{
  home.activation.deployAgentSandboxWorkdir =
    lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] ''
      sandbox_workdir="${sandboxRoot}/$(${pkgs.coreutils}/bin/id -u)"

      if ! ${pkgs.util-linux}/bin/mountpoint --quiet /sandbox; then
        echo "/sandboxがマウントされていません" >&2
        exit 1
      fi
      if [ -L "$sandbox_workdir" ] || [ ! -d "$sandbox_workdir" ]; then
        echo "永続workdirが作成されていません: $sandbox_workdir" >&2
        echo "先にagent-sandboxを一度起動して終了してください" >&2
        exit 1
      fi
      if [ "$(${pkgs.coreutils}/bin/stat -c '%u:%g' "$sandbox_workdir")" \
        != "$(${pkgs.coreutils}/bin/id -u):$(${pkgs.coreutils}/bin/id -g)" ]; then
        echo "永続workdirの所有者が一致しません: $sandbox_workdir" >&2
        exit 1
      fi
      if [ "$(${pkgs.coreutils}/bin/stat -c '%a' "$sandbox_workdir")" != 700 ]; then
        echo "永続workdirのmodeは0700である必要があります: $sandbox_workdir" >&2
        exit 1
      fi

      host_state_dir=${lib.escapeShellArg hostStateDir}
      old_manifest="$host_state_dir/managed-files"
      old_manifest_args=()
      if [ -e "$old_manifest" ]; then
        if [ -L "$old_manifest" ] || [ ! -f "$old_manifest" ]; then
          echo "管理対象manifestが通常ファイルではありません: $old_manifest" >&2
          exit 1
        fi
        old_manifest_args=(
          --ro-bind "$old_manifest" /old-manifest
        )
      fi

      $DRY_RUN_CMD ${pkgs.bubblewrap}/bin/bwrap \
        --die-with-parent \
        --unshare-user \
        --unshare-ipc \
        --unshare-pid \
        --unshare-uts \
        --unshare-cgroup-try \
        --cap-drop ALL \
        --clearenv \
        --dir /target \
        --dir /tmp \
        --dev /dev \
        --ro-bind /nix/store /nix/store \
        --bind "$sandbox_workdir" /target \
        "''${old_manifest_args[@]}" \
        ${deploySandboxWorkdir}/bin/deploy-agent-sandbox-workdir \
        "''${old_manifest_args:+/old-manifest}" \
        ${managedFiles} \
        ${deployArguments}

      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir --parents "$host_state_dir"
      manifest_tmp="$host_state_dir/managed-files.tmp.$$"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/install \
        --mode 0600 \
        ${managedFiles} \
        "$manifest_tmp"
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv \
        --no-target-directory \
        "$manifest_tmp" \
        "$old_manifest"
    '';
}
