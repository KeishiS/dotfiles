{ lib, pkgs, ... }:
{
  home.packages = [ pkgs.sheldon ];

  xdg.configFile."sheldon/plugins.toml".source = ./sheldon/plugins.toml;

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # Zsh plugins are managed by Sheldon so that the same plugins.toml can be
    # reused outside NixOS. Do not also load the Home Manager implementations.
    autosuggestion.enable = false;
    syntaxHighlighting.enable = false;

    initContent = lib.mkMerge [
      # Add external completion functions to fpath before Home Manager runs
      # compinit at order 570.
      (lib.mkOrder 550 ''
        eval "$(SHELDON_PROFILE=completion ${pkgs.sheldon}/bin/sheldon source)"
      '')

      (lib.mkOrder 1000 ''
        if [ -t 0 ]; then
          export GPG_TTY="$(${pkgs.coreutils}/bin/tty)"
          ${pkgs.gnupg}/bin/gpg-connect-agent UPDATESTARTUPTTY /bye >/dev/null 2>&1 || true
        fi
      '')

      # zsh-syntax-highlighting must be loaded after completion, custom ZLE
      # widgets, and other shell integrations.
      (lib.mkOrder 2000 ''
        eval "$(SHELDON_PROFILE=interactive ${pkgs.sheldon}/bin/sheldon source)"
      '')

      # プラグイン読込後に、Alt キーの最終的な所有権を明示する。
      (lib.mkOrder 2100 ''
        bindkey -e

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

  programs.nushell = {
    enable = true;
    extraConfig = ''
      try {
        $env.GPG_TTY = (^${pkgs.coreutils}/bin/tty | str trim)
        ^${pkgs.gnupg}/bin/gpg-connect-agent UPDATESTARTUPTTY "/bye" | ignore
      } catch {
        null
      }
    '';
  };
}
