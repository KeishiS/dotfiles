# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./sway.nix
    ];

  # Use the systemd-boot EFI boot loader.
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
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

  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 5;
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm_snapshot" "vfat" "nls_cp437" "nls_iso8859-1" "usbhid" ];

      services.lvm.enable = true;

      luks.yubikeySupport = true;
      luks.devices."nixos-root" = {
        device = "/dev/disk/by-uuid/6d5ebf4b-531b-4bf8-93ab-fb44f7a396a4";
        preLVM = false;
        yubikey = {
          slot = 1;
          twoFactor = true;
          gracePeriod = 30;
          keyLength = 64;
          saltLength = 16;
          storage = {
            device = "/dev/nvme0n1p1";
            fsType = "vfat";
            path = "/crypt-storage/default";
          };
        };
      };
    };

    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [];
  };

  # Pick only one of the below networking options.
  networking = {
    hostName = "NixOS-keishis-X13";
    # wireless.enable = true;
    networkmanager.enable = true;
  };

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [ fcitx5-mozc ];
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

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.keishis = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    initialHashedPassword = "$6$Rk3ZM8V5JpDmaggo$tADvEPoECdw7PE2JZebqch3rpsrDJAZ40JZt1aK6HpfZ9psXDy7I3XwCtoVCaMhFY8cJt.YVJuFQIExiwJgLs.";
  #   packages = with pkgs; [
  #     firefox
  #     tree
  #   ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git curl wget
    helix tmux
    networkmanagerapplet
    gcc gfortran gnumake cmake glibc zlib
  ];

  environment.variables.EDITOR = "hx";

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
  };

  programs.nano.nanorc = ''
    set softwrap
    set tabsize 4
    set tabstospaces
    set linenumbers
  '';
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
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
