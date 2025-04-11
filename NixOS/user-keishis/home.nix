{
  config,
  pkgs,
  ...
}:
rec {
  programs.home-manager.enable = true;
  home.username = "keishis";
  home.homeDirectory = "/home/keishis";

  imports = [
    ./ghostty
    ./helix
    ./sway
    ./swaylock
    ./wofi
    ./waybar
    ./zed
    ./wezterm
    ./hyprland
    ./hyprlock
    ./foot
    ./i3
  ];

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];

  home.shellAliases = {
    helix = "hx";
  };

  home.sessionVariables = {
    XCURSOR_THEME = "volantes_cursors";
    # GTK_IM_MODULE = "fcitx";
    GTK_IM_MODULE = "";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
    ELECTRON_ENABLE_WAYLAND = 0;
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
    nautilus
    glib
    seahorse
    google-chrome
    pavucontrol
    slack
    thunderbird-bin
    zoom-us
    _1password-gui
    nixd
    nixfmt-rfc-style # language server for Nix
    vlc
    postman

    # Dev Tools
    cargo-make
    cbc
    glpk
    insync
    julia_110-bin
    keybase
    quarto
    R
    rustup
    texliveFull
    typst
    yarn
    pipx
    cloud-utils
    gh
    uv
    hugo
    shfmt # for shellscript formatter
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
      /*
        package = pkgs.tokyonight-gtk-theme;
        name = "Tokyonight-Dark";
      */
      package = pkgs.tela-icon-theme;
      name = "Tela-nord-dark";
    };
    cursorTheme = {
      package = pkgs.volantes-cursors;
      name = "volantes_cursors";
    };
    gtk3.extraConfig = {
      gtk-im-module = "fcitx";
    };
    gtk4.extraConfig = {
      gtk-im-module = "fcitx";
    };
  };

  editorconfig = {
    enable = true;
    settings."*" = {
      charset = "utf-8";
      trim_trailing_whitespace = true;
      indent_style = "space";
      indent_size = 4;
      insert_final_newline = true;
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
      credential.helper = "cache --timeout=3600";
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

  home.file.".latexmkrc".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/.latexmkrc";

  xdg.configFile = {
    "home-manager".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/NixOS/user-keishis";
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    desktop = "${home.homeDirectory}/Desktop";
    documents = "${home.homeDirectory}/Documents";
    download = "${home.homeDirectory}/Downloads";
    music = "${home.homeDirectory}/Music";
    pictures = "${home.homeDirectory}/Pictures";
    publicShare = "${home.homeDirectory}/Public";
    templates = "${home.homeDirectory}/Templates";
    videos = "${home.homeDirectory}/Videos";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/gitkraken" = "GitKraken.desktop";
      "x-scheme-handler/mailspring" = "org.mozilla.Thunderbird.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/postman" = "Postman.desktop";
      "text/html" = "firefox.desktop";
      "text/xml" = "firefox.desktop";
      "text/mml" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
    };
  };

  xdg.autostart = {
    enable = true;
    entries = [
      "${pkgs.insync}/share/applications/insync.desktop"
      "${pkgs.networkmanagerapplet}/share/applications/nm-applet.desktop"
    ];
  };

  home.stateVersion = "24.11"; # Please read the comment before changing.
}
