{ pkgs, ... }:
{
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
}
