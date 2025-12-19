{ pkgs, ... }:
{
  programs.gnupg.agent = {
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

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
      noto-fonts-color-emoji
      source-han-code-jp
      ipaexfont
      moralerspace
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.noto
    ];
  };

  services.gnome.gnome-keyring.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    wireplumber.enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    swaynotificationcenter
    wofi
    wl-clipboard
    grim
    slurp
    ghostty
    wdisplays
    brightnessctl
  ];
  programs.waybar.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  programs.xwayland.enable = true;
}
