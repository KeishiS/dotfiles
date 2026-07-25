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
        typeset -a tmux_meta_keys=(
          $'\eh' $'\ej' $'\ek' $'\el'
          $'\e[' $'\e]' $'\e\r' $'\ez' $'\et'
          $'\e1' $'\e2' $'\e3' $'\e4' $'\e5'
          $'\e6' $'\e7' $'\e8' $'\e9'
        )
        typeset -a tmux_zle_keymaps=(
          emacs viins vicmd viopp visual isearch command
        )
        for tmux_zle_keymap in "''${tmux_zle_keymaps[@]}"; do
          for tmux_meta_key in "''${tmux_meta_keys[@]}"; do
            bindkey -M "$tmux_zle_keymap" -r "$tmux_meta_key" 2>/dev/null || true
          done
        done
        unset tmux_meta_key tmux_meta_keys tmux_zle_keymap tmux_zle_keymaps

        # Alt+t の transpose-words は上で解除済み。Alt+f/b/d は Zsh が所有する。
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
