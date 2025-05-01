{ config, ... }:
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "${config.home.homeDirectory}/dotfiles/wallpaper/wallpaper01.png"
      ];
      wallpaper = [
        ",${config.home.homeDirectory}/dotfiles/wallpaper/wallpaper01.png"
      ];
    };
  };
}
