{ pkgs, ... }:
{
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;
  programs.hyprland.withUWSM = true;
  security.pam.services.hyprland.enableGnomeKeyring = true;

  environment.systemPackages = with pkgs; [
    hyprpolkitagent
  ];
}
