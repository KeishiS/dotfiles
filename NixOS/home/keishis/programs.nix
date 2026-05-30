{ pkgs, ... }:
{
  editorconfig = {
    enable = true;
    settings."*" = {
      charset = "utf-8";
      trim_trailing_whitespace = true;
      indent_style = "space";
      indent_size = 4;
      insert_final_newline = true;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      if [ -t 0 ]; then
        export GPG_TTY="$(${pkgs.coreutils}/bin/tty)"
        ${pkgs.gnupg}/bin/gpg-connect-agent UPDATESTARTUPTTY /bye >/dev/null 2>&1 || true
      fi
    '';
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

  programs.starship.enable = true;

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
      # obs-webkitgtk
      advanced-scene-switcher
    ];
  };
}
