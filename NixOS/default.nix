{ config, lib, pkgs, ... }:
{
  nix = {
    settings.experimental-features = [
      "nix-command" "flakes" ];
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

  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Tokyo";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
    ];
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc ];
    };
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "jp106";
  #   useXkbConfig = true; # use xkb.options in tty.
  };
  services.xserver = {
    xkb.layout = "jp";
    xkb.model = "jp106";
  };

  users.users.keishis = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
    initialHashedPassword = "$6$Rk3ZM8V5JpDmaggo$tADvEPoECdw7PE2JZebqch3rpsrDJAZ40JZt1aK6HpfZ9psXDy7I3XwCtoVCaMhFY8cJt.YVJuFQIExiwJgLs.";
  };

  environment.systemPackages = with pkgs; [
    git curl wget
    helix tmux
    networkmanagerapplet
    gcc gfortran gnumake cmake glibc zlib
    unzip
    pinentry-curses
    xkeyboard_config # `sway --debug` `xkbcommon: ERROR: couldn't find a Compose file for locale "en_US.UTF-8"`
  ];
  environment.variables.EDITOR = "hx";

  programs.nano.nanorc = ''
    set softwrap
    set tabsize 4
    set tabstospaces
    set linenumbers
  '';

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

  fonts = {
    fontDir.enable = true;
    enableDefaultPackages = true;
    packages = with pkgs; [
      fira-code
      fira-code-symbols
      jetbrains-mono
      julia-mono
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      source-han-code-jp
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "JetBrainsMono"
          "Noto"
        ];
      })
    ];
  };

  nixpkgs.config.allowUnfree = true;
}