{ config, lib, pkgs, ... }:
{
  services.displayManager = {
    defaultSession = "sway";

    sddm = {
      enable = true;
      wayland.enable = true;
      theme = "catppuccin-mocha";
      package = pkgs.kdePackages.sddm;
    };
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  programs.waybar.enable = true;

  services.gnome.gnome-keyring.enable = true;
  environment.systemPackages = with pkgs; [
    (catppuccin-sddm.override {
      flavor = "mocha";
    })
    swaybg
    swaylock-effects
    swaynotificationcenter
    wofi
    wl-clipboard
    grim
    slurp
    wezterm
    wdisplays
    brightnessctl
  ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  programs.gnupg.agent = {
    pinentryPackage = pkgs.pinentry-gnome3;
  };
}
