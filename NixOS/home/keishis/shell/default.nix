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

      # tmux が所有する Alt 名前空間を ZLE から明示的に解除する。
      (lib.mkOrder 1900 ''
        typeset -a tmux_meta_keys=(
          $'\eh' $'\ej' $'\ek' $'\el'
          $'\e[' $'\e]' $'\e\r' $'\ez' $'\et'
          $'\e1' $'\e2' $'\e3' $'\e4' $'\e5'
          $'\e6' $'\e7' $'\e8' $'\e9'
        )
        for tmux_meta_key in "''${tmux_meta_keys[@]}"; do
          bindkey -M emacs -r "$tmux_meta_key" 2>/dev/null || true
          bindkey -M viins -r "$tmux_meta_key" 2>/dev/null || true
        done
        unset tmux_meta_key tmux_meta_keys

        # シェルの単語操作用 Alt キーは tmux で奪わず、ZLE に固定する。
        bindkey -M emacs $'\ef' forward-word
        bindkey -M emacs $'\eb' backward-word
        bindkey -M emacs $'\ed' kill-word
      '')

      # zsh-syntax-highlighting must be loaded after completion, custom ZLE
      # widgets, and other shell integrations.
      (lib.mkOrder 2000 ''
        eval "$(SHELDON_PROFILE=interactive ${pkgs.sheldon}/bin/sheldon source)"
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
