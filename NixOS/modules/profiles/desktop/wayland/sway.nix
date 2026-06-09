{ pkgs, ... }:
{
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

  xdg.portal = {
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
}
