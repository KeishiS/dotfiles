{ config, lib, pkgs, ... }:
{
  services.displayManager = {
    defaultSession = "sway";

    sddm = {
      enable = true;
      wayland.enable = true;
      theme = "catppuccin-mocha";
    };
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  programs.waybar.enable = true;
  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = with pkgs; [
    catppuccin-sddm.override {
      flabor = "mocha";
    }
    swaybg
    swaynotificationcenter
    wofi
    wl-clipboard
    grim
    slurp
    wezterm
  ];
}