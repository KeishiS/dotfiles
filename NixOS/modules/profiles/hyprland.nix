{ lib, pkgs, ... }:
{
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;
  programs.hyprland.withUWSM = true;
  xdg.portal.enable = lib.mkForce false;
  security.pam.services.hyprland.enableGnomeKeyring = true;

  environment.systemPackages = with pkgs; [
    hyprpolkitagent
  ];
}
