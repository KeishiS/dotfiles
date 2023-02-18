# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Use the systemd-boot EFI boot loader.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = ["vfat" "uas" "usbcore" "usb_storage" "nls_cp437" "nls_iso8859_1"];
  boot.initrd.postDeviceCommands = pkgs.lib.mkBefore ''
    mkdir -m 0755 -p /key
    sleep 3
    mount -n -t vfat -o ro /dev/disk/by-label/KEYCASE /key
  '';
  boot.initrd.luks.devices = {
    unlocked = {
      device = "/dev/mapper/nixos-root";
      keyFile = "/key/keyfile";
      preLVM = false;
    };
  };
  
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 1d";

  networking.hostName = "nobuta-nixos-XXXXX"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  programs.nm-applet.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "ja_JP.UTF-8";
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx.engines = with pkgs.fcitx-engines; [mozc];
    fcitx5.addons = with pkgs; [fcitx5-mozc];
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "jp106";
  #   useXkbConfig = true; # use xkbOptions in tty.
  };

  # needed for store VS Code token
  services.gnome.gnome-keyring.enable = true;  

  # Configure keymap in X11 & for zsh completion
  environment.pathsToLink = ["/libexec" "/share/zsh"];
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  services.xserver = {
    enable = true;
    layout = "jp";
    
    # videoDrivers = ["nvidia"];
    synaptics.enable = false;
    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
      lightdm.enable = true;
      defaultSession = "none+i3";
      sessionCommands = ''
        xrdb "${pkgs.writeText "xrdb.conf" ''
	      URxvt*scrollstyle:        plain
	      URxvt*scrollBar_right:    true
	      URxvt*scrollBar_floating: true
	      URxvt*cursorUnderline:    true
	      URxvt*background:         #121214
	      URxvt*foreground:         #FFFFFF
	      ! black
	      URxvt*color0:             #2E3436
	      URxvt*color8:             #555753
	      ! red
	      URxvt*color1:             #CC0000
	      URxvt*color9:             #EF2929
	      ! green
	      URxvt*color2:             #4E9A06
	      URxvt*color10:            #8AE234
	      ! yellow
	      URxvt*color3:             #C4A000
	      URxvt*color11:            #FCE94F
	      ! blue
	      URxvt*color4:             #3465A4
	      URxvt*color12:            #729FCF
	      ! magenta
	      URxvt*color5:             #755078
	      URxvt*color13:            #AD7FA8
	      ! cyan
	      URxvt*color6:             #06989A
	      URxvt*color14:            #34E2E2
	      ! white
	      URxvt*color7:             #D3D7CF
	      URxvt*color15:            #EEEEEC
	      URxvt*imLocale:           ja_JP.UTF-8
          URxvt*font:               xft:Iosevka:size=16:antialias=true,\
                                    xft:SourceHanCodeJP:size=16:antialias=true
        ''}"
      '';
    };
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        polybar
      ];
    };
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  fonts = {
    fontDir.enable = true;
    enableDefaultFonts = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      jetbrains-mono
      source-han-code-jp
      symbola
      iosevka
      ipaexfont
      ipafont
      fira-code
      material-design-icons
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      source-han-mono
      source-han-sans
      source-han-serif
    ];
    fontconfig = {
      defaultFonts = {
        serif = ["Source Han Serif" "Noto Serif CJK JP"];
        sansSerif = ["Source Han Sans" "Noto Sans CJK JP"];
        monospace = ["Fira Code" "Source Han Mono" "Noto Sans Mono CJK JP"];
        emoji = ["Noto Color Emoji"];
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     firefox
  #     thunderbird
  #   ];
  # };
  users.users.nobuta05 = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    arandr
    authy
    betterlockscreen
    biber
    blueman
    bluez
    cbc
    cmake
    colordiff
    discord
    docker
    dunst
    enpass
    gcc
    git
    gfortran
    glpk
    gnumake
    google-chrome
    google-drive-ocamlfuse
    graphviz
    home-manager
    http-parser
    jq
    julia
    lapack
    maim
    mate.atril
    nomacs
    pavucontrol
    pciutils
    poppler_data
    pulseaudio
    pulseaudio-ctl
    quarto
    rename
    rofi
    rstudio
    simplescreenrecorder
    slack
    texlive.combined.scheme-full
    tk
    tmux
    unicode-emoji
    unzip
    volumeicon
    vscode
    wezterm
    xclip
    xdg-user-dirs
    xsel
    zip
    zoom-us
    zsh
    R
  ];

  environment.variables.EDITOR = "nano";
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

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    curl
    nghttp2
  ];
  environment.variables = {
    JULIA_SSL_CA_ROOTS_PATH="/etc/ssl/certs/ca-bundle.crt";
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

