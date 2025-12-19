{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../pkgs/sops-nix/defaultnix
  ];
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    settings.auto-optimise-store = true;
    gc = {
      dates = "daily";
      options = "--delete-older-than 3d";
      automatic = true;
    };
    optimise = {
      automatics = true;
      dates = [ "daily" ];
    };
  };

  boot.initrd.systemd.enable = true; # initrdでsystemdを使用(systemd-cryptenroll/FIDO2のため)
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 5;
    efi.canTouchEfiVariables = true;
  };
  services.logind.lidSwitch = "suspend"; # 蓋を閉じた際の挙動をsuspendに固定
  boot.resumeDevice = ""; # ランダムswapを使っているためハイバネーション(resume)を無効化

  # FIDO2デバイスでlogin/sudoできるように
  security.pam = {
    services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
    };
    u2f = {
      enable = true;
      settings = {
        cue = true;
        pinverification = 1;
        userpresence = 1;
      };
    };
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  services.pcscd.enable = true;
  services.udev.extraRules = ''
    ACTION=="remove", ENV{ID_VENDOR_ID}=="1050", ENV{ID_MODEL_ID}=="0407", RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
  '';

  networking.hostFiles = [
    "${config.sops.secrets.hosts.path}"
  ];
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.macAddress = "random";
  networking.firewall.enable = true;

  time.timeZone = "Asia/Tokyo";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
    ];
    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
          kdePackages.fcitx5-qt
        ];
        settings.inputMethod = {
          GroupOrder."0" = "Default";
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "jp106";
            DefaultIM = "mozc";
          };
          "Groups/0/Items/0".Name = "mozc";
        };
      };
    };
  };
  environment.variables.GTK_IM_MODULE = lib.mkForce "";

  console = {
    earlySetup = true;
    packages = with pkgs; [ spleen ];
    font = "${pkgs.spleen}/share/consolefonts/spleen-16x32.psfu";
    # font = "Lat2-Terminus16";
    keyMap = "jp106";
  };
  services.xserver = {
    xkb.layout = "jp";
    xkb.model = "jp106";
  };

  users.users.keishis = {
    isNormalUser = true;
    home = "/home/keishis";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    initialHashedPassword = "$6$Rk3ZM8V5JpDmaggo$tADvEPoECdw7PE2JZebqch3rpsrDJAZ40JZt1aK6HpfZ9psXDy7I3XwCtoVCaMhFY8cJt.YVJuFQIExiwJgLs.";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLPYWxCTckCVdDiBpiKWE8omDndrvQhWkscX8uIyd1j openpgp:0xD1E438FC"
    ];
  };

  environment.systemPackages = with pkgs; [
    git
    git-crypt
    curl
    wget
    helix
    tmux
    gcc
    gfortran
    gnumake
    cmake
    glibc
    zlib
    zip
    unzip
    gptfdisk
    colordiff
    pinentry-curses
    xkeyboard_config # `sway --debug` `xkbcommon: ERROR: couldn't find a Compose file for locale "en_US.UTF-8"`
    home-manager
    pkg-config # for common library directory path, e.g., openssl
    yubikey-manager
    yubikey-personalization # for using `ykchalresp`
    sops

    ## for podman
    # podman
    # dive
    # podman-tui

    openblas
  ];

  environment.variables = {
    EDITOR = "hx";
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };

  programs.nano.nanorc = ''
    set softwrap
    set tabsize 4
    set tabstospaces
    set linenumbers
  '';

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    enableExtraSocket = true;
  };

  programs.nix-ld.dev.enable = true;
  nixpkgs.config.allowUnfree = true;
}
