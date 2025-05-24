{ pkgs, ... }:
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

  #　for podman
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  environment.systemPackages = with pkgs; [
    (catppuccin-sddm.override {
      flavor = "mocha";
    })

    #　for podman
    dive
    podman-tui
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
      ghostty
      foot
      wdisplays
      brightnessctl
      wl-screenrec
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
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
    config.sway = {
      "org.freedesktop.impl.portal.ScreenCast" = "wlr";
      "org.freedesktop.impl.portal.Screenshot" = "wlr";
      "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
      "org.freedesktop.impl.portal.FileChooser" = "gtk";
    };
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

  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    packages = with pkgs; [
      fira-code
      fira-code-symbols
      jetbrains-mono
      julia-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      source-han-code-jp
      ipaexfont
      monaspace
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.noto
    ];
  };
}
