{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;
  home.username = "keishis";
  home.homeDirectory = "/home/keishis";

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];

  home.shellAliases = {
    helix = "hx";
  };

  home.sessionVariables = {
    XCURSOR_THEME = "volantes_cursors";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
    # NIXOS_OZONE_WL = "1"; # これを有効化するとwaylandネイティブなアプリが立ち上がり，日本語入力ができなくなる
  };

  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    # Basic utilities
    dex
    file
    jq
    nfs-utils
    pdfgrep
    poppler_utils
    unzip
    ffmpeg

    # GUI Apps
    discord
    firefox
    evince
    gitkraken
    nautilus glib
    seahorse
    google-chrome
    pavucontrol
    slack
    thunderbird
    zoom-us
    _1password-gui
    zed-editor
    element-desktop
    vlc
    freecad
    orca-slicer
    postman

    # Dev Tools
    cargo-make
    cbc
    glpk
    insync
    julia_110-bin
    keybase
    nixd
    quarto
    R
    rustup
    texliveFull
    typst
    nodejs_18
    yarn
    pipx
    cloud-utils
    gh
    uv
    hugo
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
        editor = "hx";
        quotepath = false;
      };
      commit.gpgsign = true;
      github.user = "KeishiS";
      init.defaultBranch = "main";
      merge.ff = false;
      push.default = "simple";
      pull.rebase = true;
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.nushell = {
    enable = true;
  };

  programs.starship = {
    enable = true;
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-pipewire-audio-capture
      obs-webkitgtk
      advanced-scene-switcher
    ];
  };

  home.file = {
    ".latexmkrc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.latexmkrc";
  };

  xdg.configFile = {
    "foot".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/foot";
    "helix".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/helix";
    "home-manager".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/NixOS/user-keishis";
    "sway".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/sway";
    "swaylock".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/swaylock";
    "waybar".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/waybar";
    "wezterm".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/wezterm";
    "wofi".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/wofi";
    "zed".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/zed";

    "autostart".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/autostart";
    "user-dirs.dirs".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/user-dirs.dirs";
    "mimeapps.list".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.config/mimeapps.list";
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.
}
