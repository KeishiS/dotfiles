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
    # Zsh plugins are managed by Sheldon to avoid loading them twice through
    # both Home Manager and Sheldon.
    autosuggestion.enable = false;
    syntaxHighlighting.enable = false;

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

      # プラグイン読込後に、Alt キーの最終的な所有権を明示する。
      (lib.mkOrder 2100 ''
        typeset -a reserved_meta_keys=(
          $'\eh' $'\ej' $'\ek' $'\el'
          $'\e[' $'\e]' $'\e\r' $'\ez' $'\et'
          $'\e1' $'\e2' $'\e3' $'\e4' $'\e5'
          $'\e6' $'\e7' $'\e8' $'\e9'
        )
        typeset -a reserved_zle_keymaps=(
          emacs viins vicmd viopp visual isearch command
        )
        for reserved_zle_keymap in "''${reserved_zle_keymaps[@]}"; do
          for reserved_meta_key in "''${reserved_meta_keys[@]}"; do
            bindkey -M "$reserved_zle_keymap" -r "$reserved_meta_key" 2>/dev/null || true
          done
        done
        unset reserved_meta_key reserved_meta_keys reserved_zle_keymap reserved_zle_keymaps

        # Alt+t とタブ操作は tmux が所有し、旧ペイン操作用 Alt キーは無効。
        # Alt+f/b/d だけは Zsh が所有する。
        bindkey -M emacs $'\ef' forward-word
        bindkey -M emacs $'\eb' backward-word
        bindkey -M emacs $'\ed' kill-word
      '')
    ];
  };
}
