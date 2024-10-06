{ config, pkgs, ... }:
{
  programs.home-manager.enable = true;
  home.username = "keishis";
  home.homeDirectory = "/home/keishis";

  home.sessionVariables = {
    XCURSOR_THEME = "volantes_cursors";
  };

  home.packages = with pkgs; [
    file
    jq
    unzip
    dex # a program to generate and execute DesktopEntry files of the Application type
    nixd # Nix language server
    julia-bin
    poetry
    texliveFull
    gnome.nautilus glib
    insync
    firefox
    google-chrome
    _1password-gui
    cbc
    glpk
    discord
    evince
    gnome.seahorse
    nfs-utils
    pavucontrol
    pdfgrep
    R
    thunderbird
    typst
    gitkraken
    keybase
    quarto
    slack
    zoom-us
  ];

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.volantes-cursors;
    name = "volantes_cursors";
    size = 24;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.orchis-theme;
      name = "Orchis-Dark";
    };
    iconTheme = {
      /* package = pkgs.tokyonight-gtk-theme;
      name = "Tokyonight-Dark"; */
      package = pkgs.tela-icon-theme;
      name = "Tela-nord-dark";
    };
    cursorTheme = {
      package = pkgs.volantes-cursors;
      name = "volantes_cursors";
    };
  };

  programs.git = {
    enable = true;
    userName = "KeishiS";
    userEmail = "sando.keishi.sp@alumni.tsukuba.ac.jp";
    diff-so-fancy.enable = true;
    diff-so-fancy.stripLeadingSymbols = false;
    extraConfig = {
      core = {
        editor = "helix";
        quotepath = false;
      };
      commit = {
        gpgsign = true;
      };
      github = {
        user = "KeishiS";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };

  programs.gpg.settings = {
    pinentry-program = "pinentry-gtk2";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.starship = {
    enable = true;
  };

  home.sessionVariables.NIXOS_OZONE_WL = "1";
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  xdg.configFile = {
    # "gtk-3.0".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/gtk-3.0";
    "helix".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/helix";
    "sway".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/sway";
    "swaylock".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/swaylock";
    "waybar".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/waybar";
    "wezterm".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/wezterm";
    "wofi".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/wofi";
    "autostart".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/autostart";

    "user-dirs.dirs".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/user-dirs.dirs";
    "mimeapps.list".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/mimeapps.list";
  };
  home.file = {
    ".latexmkrc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.latexmkrc";
  };

  home.stateVersion = "24.05";
}
