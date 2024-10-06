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
  environment.systemPackages = with pkgs; [
    (catppuccin-sddm.override {
      flavor = "mocha";
    })
  ];

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraOptions = [
      "--debug"
    ];
    extraPackages = with pkgs; [
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
  };
  programs.waybar.enable = true;

  services.gnome.gnome-keyring.enable = true;

  xdg.portal = {
    # [for discord]
    # Failed to call method: org.freedesktop.DBus.Properties.Get:
    # object_path= /org/freedesktop/portal/desktop: org.freedesktop.DBus.Error.InvalidArgs:
    # No such interface “org.freedesktop.portal.FileChooser”
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    wireplumber.enable = true;
  };

  programs.gnupg.agent = {
    pinentryPackage = pkgs.pinentry-gtk2;
  };
}
