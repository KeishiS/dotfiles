{ config, ... }:
let
  wallpaper = "${config.home.homeDirectory}/dotfiles/wallpaper/wallpaper01.png";
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        wallpaper
      ];
      wallpaper = [
        {
          monitor = "";
          path = wallpaper;
        }
      ];
    };
  };
}
