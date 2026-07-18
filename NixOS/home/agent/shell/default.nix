{ lib, pkgs, ... }:
{
  home.packages = [ pkgs.sheldon ];

  xdg.configFile."sheldon/plugins.toml".source = ./sheldon/plugins.toml;

  programs.bash = {
    enable = true;
    enableCompletion = true;

    shellAliases = {
      ls = "eza --group-directories-first --icons=auto";
      ll = "eza -lh --group-directories-first --icons=auto";
      la = "eza -lah --group-directories-first --icons=auto";
      cat = "bat --paging=never";
    };

    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
    historyFile = "$HOME/.local/state/bash/history";
    historyFileSize = 10000;
    historySize = 10000;

    profileExtra = ''
      if [[ $- == *i* ]] && command -v zsh >/dev/null 2>&1; then
        exec zsh -l
      fi
    '';

    initExtra = ''
      mkdir -p "$HOME/.local/state/bash"
      if [[ -d /workspace ]]; then
        cd /workspace
      fi
    '';
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true; # 補完エンジンの起動
    autosuggestion.enable = false; # sheldon で管理
    syntaxHighlighting.enable = false; # sheldon で管理

    shellAliases = {
      ls = "eza --group-directories-first --icons=auto";
      ll = "eza -lh --group-directories-first --icons=auto";
      la = "eza -lah --group-directories-first --icons=auto";
      cat = "bat --paging=never";
    };

    history = {
      path = "$HOME/.local/state/zsh/history";
      save = 10000;
      size = 10000;
      share = true;
    };

    initContent = lib.mkMerge [
      (lib.mkOrder 550 ''
        eval "$(SHELDON_PROFILE=completion ${pkgs.sheldon}/bin/sheldon source)"
      '')

      (lib.mkOrder 1000 ''
        export SHELL="${pkgs.zsh}/bin/zsh"
        mkdir -p "$HOME/.local/state/zsh"
        if [[ -d /workspace ]]; then
          cd /workspace
        fi
      '')

      # Syntax highlighting must be loaded after completion and other ZLE
      # integrations.
      (lib.mkOrder 2000 ''
        eval "$(SHELDON_PROFILE=interactive ${pkgs.sheldon}/bin/sheldon source)"
      '')
    ];
  };
}
