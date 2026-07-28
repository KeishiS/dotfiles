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
    ./xdg.nix
    ./editorconfig
    ./shell
    ./starship

    ./sway
    ./swaylock
    ./wofi
    ./waybar
    ./hyprland
    ./i3
    ./sops-nix

    # terminal
    ./ghostty
    ./kitty
    ./tmux
    ./zellij
    ./rio
    ./foot
    ./wezterm

    # editor
    ./vim
    ./helix
    ./zed
    ./vscode

    # media
    ./obs-studio
  ];

  services.swaync.enable = true;

  home.stateVersion = "26.05";
}
