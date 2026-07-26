{ pkgs, ... }:
{
  imports = [
    ./starship
    ./vim
  ];

  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
