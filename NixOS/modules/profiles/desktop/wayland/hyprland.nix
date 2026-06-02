{ pkgs, ... }:
{
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;
  programs.hyprland.withUWSM = true;
  security.pam.services.hyprland.enableGnomeKeyring = true;

  xdg.portal.config.hyprland = {
    default = [
      "hyprland"
      "gtk"
    ];
    "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
    "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
    "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
  };

  environment.systemPackages = with pkgs; [
    hyprpolkitagent
  ];
}
