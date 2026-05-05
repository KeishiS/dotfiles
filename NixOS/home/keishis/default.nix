{ ... }:
{
  programs.home-manager.enable = true;
  home.username = "keishis";
  home.homeDirectory = "/home/keishis";

  imports = [
    ./appearance
    ./packages.nix
    ./session.nix
    ./gtk.nix
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
    # ./mail-notify
    ./sops-nix

    # terminal
    ./ghostty
    ./rio
    ./foot

    # editor
    ./helix
    ./zed
  ];

  /*
    services.mailNotify = {
      enable = true;
      accounts.personal = {
        email = "nobuta05@gmail.com";
        host = "imap.gmail.com";
        xoAuth2 = true;
        oauth2 = {
          enable = true;
          clientIdFile = ./sops-nix/secrets/mail-personal-oauth-client-id.enc;
          clientSecretFile = ./sops-nix/secrets/mail-personal-oauth-client-secret.enc;
          refreshTokenFile = ./sops-nix/secrets/mail-personal-oauth-refresh-token.enc;
        };
      };
    };
  */

  home.stateVersion = "24.11"; # Please read the comment before changing.
}
