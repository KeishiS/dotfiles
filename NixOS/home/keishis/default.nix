{ ... }:
{
  programs.home-manager.enable = true;
  home.username = "keishis";
  home.homeDirectory = "/home/keishis";

  imports = [
    ./appearance.nix
    ./packages.nix
    ./session.nix
    ./gnupg.nix
    ./git.nix
    ./programs.nix
    ./xdg.nix

    ./sway
    ./swaylock
    ./wofi
    ./waybar
    ./wezterm
    ./hyprland
    ./hyprpaper
    ./hyprlock
    ./hypridle
    ./i3
    ./sops-nix

    # terminal
    ./ghostty
    ./rio
    ./foot

    # editor
    ./helix
    ./zed
  ];

  home.stateVersion = "24.11"; # Please read the comment before changing.
}
