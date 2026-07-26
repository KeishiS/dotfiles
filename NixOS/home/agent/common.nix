{ pkgs, ... }:
{
  imports = [
    # ./shell
    ./starship
    ./vim
  ];

  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
}
