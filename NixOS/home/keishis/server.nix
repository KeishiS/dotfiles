{ ... }:
{
  programs.home-manager.enable = true;

  home = {
    username = "keishis";
    homeDirectory = "/home/keishis";
    stateVersion = "26.05";
  };

  imports = [
    ./shell/zsh-sheldon.nix
    ./starship
  ];
}
