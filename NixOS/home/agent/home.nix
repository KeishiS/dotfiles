{ pkgs, ... }:
{
  imports = [
    ./shell
    ./vim
    ./zellij
    ./agent-tools.nix
  ];

  home = {
    username = "agent";
    homeDirectory = "/users/agent";
    stateVersion = "26.05";

    packages = with pkgs; [
      bat
      eza
      fd
      jq
      ripgrep
    ];

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.local/share/pnpm"
    ];

    sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
      PNPM_HOME = "$HOME/.local/share/pnpm";
    };
  };

  programs.home-manager.enable = true;
}
