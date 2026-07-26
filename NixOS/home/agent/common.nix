{ pkgs, ... }:
{
  imports = [
    ./starship
    ./vim
  ];

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
}
