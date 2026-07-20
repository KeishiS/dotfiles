{ pkgs, ... }:
{
  imports = [
    ./shell
    ./starship
    ./vim
    ./zellij
  ];

  home = {
    username = "agent";
    stateVersion = "26.05";

    packages = with pkgs; [
      bat
      eza
      fd
      gitFull
      jq
      ripgrep
    ];

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.local/share/pnpm/bin"
    ];

    sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
      PNPM_HOME = "$HOME/.local/share/pnpm";
      PNPM_CONFIG_GLOBAL_BIN_DIR = "$HOME/.local/share/pnpm/bin";
    };
  };

  programs.home-manager.enable = true;
}
