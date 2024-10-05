{ config, pkgs, lib, ... }:
{
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    file
    jq
    unzip
    dex # a program to generate and execute DesktopEntry files of the Application type
  ];

  wayland.windowManager.sway = {
    enable = true;
  };

  programs.starship = {
    enable = true;
  };

  home.sessionVariables.NIXOS_OZONE_WL = "1";
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  home.stateVersion = "24.05";
}
