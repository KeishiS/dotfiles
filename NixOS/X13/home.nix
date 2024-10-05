{ config, pkgs, ... }:
{
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    file
    jq
    unzip
  ];

  programs.starship = {
    enable = true;
  };
}
