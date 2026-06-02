{ config, pkgs, ... }:
{
  # home.file.".latexmkrc".source =
  #   config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.latexmkrc";

  xdg.configFile = {
    "home-manager".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/NixOS/home/keishis";
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = false;

    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    publicShare = "${config.home.homeDirectory}/Public";
    templates = "${config.home.homeDirectory}/Templates";
    videos = "${config.home.homeDirectory}/Videos";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/gitkraken" = "GitKraken.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "text/html" = "firefox.desktop";
      "text/xml" = "firefox.desktop";
      "text/mml" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
    };
  };

  xdg.autostart = {
    enable = true;
    entries = [
      "${pkgs.networkmanagerapplet}/share/applications/nm-applet.desktop"
    ];
  };
}
