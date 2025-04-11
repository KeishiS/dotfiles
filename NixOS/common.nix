{
  lib,
  pkgs,
  ragenix,
  my-secrets,
  config,
  ...
}:
{
  age.secrets = {
    mackerel_apikey = {
      file = "${my-secrets}/mackerel_apikey.age";
      mode = "0400";
      owner = "root";
      group = "root";
    };

    hosts = {
      file = "${my-secrets}/hosts.age";
      mode = "0400";
      owner = "root";
      group = "root";
    };
  };

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
  };

  security.sudo.wheelNeedsPassword = false;

  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };

    extraHosts = ''
      192.168.10.4 nixos-keishis-home
    '';
  };
  time.timeZone = "Asia/Tokyo";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
    ];
  };
  console = {
    earlySetup = true;
    packages = with pkgs; [ spleen ];
    font = "${pkgs.spleen}/share/consolefonts/spleen-16x32.psfu";
    keyMap = "jp106";
  };

  users.users.sandi = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    # `mkpasswd -m sha-512`
    initialHashedPassword = "$6$ooF34UYoB/VlBMyE$ifIIU4dmFNwgPTsvP5rNQ4LMR/D/rU5XkxvZJa73vi4TbjZSZBGSBitXFlJFugBgVTgH5zJ9rhdpayy4Sgrei/";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLPYWxCTckCVdDiBpiKWE8omDndrvQhWkscX8uIyd1j openpgp:0xD1E438FC"
    ];
  };

  environment.systemPackages = with pkgs; [
    git
    nano
    ghostty.terminfo
    wget
    curl
    lsof
    gcc
    julia_110-bin
    lapack
    helix
    zip
    unzip
    mackerel-agent
    nfs-utils
    pinentry-curses
  ];
  environment.variables.EDITOR = "hx";

  programs.nano = {
    nanorc = ''
      set softwrap
      set tabsize 4
      set tabstospaces
      set linenumbers
    '';
  };

  programs.starship.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    enableExtraSocket = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = lib.mkDefault false;
    extraConfig = ''
      AllowAgentForwarding yes
    '';
  };

  services.mackerel-agent = {
    apiKeyFile = config.age.secrets.mackerel_apikey.path;
    enable = true;
    runAsRoot = true;
  };
}
