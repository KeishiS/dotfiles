{
  pkgs,
  # ragenix,
  # my-secrets,
  ...
}:
{
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    settings.auto-optimise-store = true;
    gc = {
      dates = "weekly";
      options = "--delete-older-than 5d";
      automatic = true;
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };

  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 5;
    efi.canTouchEfiVariables = true;
  };

  # FIDO2デバイスでlogin/sudoできるように
  security.pam = {
    services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
    };
    u2f.cue = true;
  };

  services.pcscd.enable = true;
  services.udev.extraRules = ''
    ACTION=="remove", ENV{ID_VENDOR_ID}=="1050", ENV{ID_MODEL_ID}=="0407", RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
  '';

  networking.networkmanager.enable = true;
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
        # waylandFrontend = true;
        addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
        ];
      };
    };
  };
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

  /*
    age.secrets.config = {
      file = "${my-secrets}/ssh_config.age";
      path = "/home/keishis/.ssh/config";
      mode = "0400";
      owner = "keishis";
      group = "wheel";
    };
  */

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    helix
    tmux
    networkmanagerapplet
    gcc
    gfortran
    gnumake
    cmake
    glibc
    zlib
    zip
    unzip
    gptfdisk
    pinentry-curses
    xkeyboard_config # `sway --debug` `xkbcommon: ERROR: couldn't find a Compose file for locale "en_US.UTF-8"`
    home-manager
    colmena
    pkg-config # for common library directory path, e.g., openssl
    yubikey-manager
    yubikey-personalization # for using `ykchalresp`
  ];
  /*
    ++ [
      ragenix.packages.x86_64-linux.default
    ];
  */
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
