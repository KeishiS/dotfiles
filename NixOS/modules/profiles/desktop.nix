{ config, pkgs, ... }:
let
  tuigreetXsessionWrapper = pkgs.writeShellScript "tuigreet-xsession-wrapper" ''
    export PATH="${
      pkgs.lib.makeBinPath [
        pkgs.coreutils
        pkgs.xauth
        pkgs.xinit
      ]
    }:$PATH"

    export XINITRC=/etc/X11/xinit/xinitrc
    exec ${pkgs.xinit}/bin/startx
  '';
in
{
  programs.gnupg.agent = {
    pinentryPackage = pkgs.pinentry-gnome3;
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
      noto-fonts-cjk-sans-static
      noto-fonts-cjk-serif-static
      noto-fonts-color-emoji
      source-han-code-jp
      ipaexfont
      moralerspace
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.noto

      vollkorn # for basic-report in typst
    ];
  };

  services.gnome.gnome-keyring.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    wireplumber.enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.tuigreet}/bin/tuigreet \
            --time \
            --asterisks \
            --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions \
            --xsessions ${config.services.displayManager.sessionData.desktops}/share/xsessions \
            --xsession-wrapper ${tuigreetXsessionWrapper}
        '';
      };
    };
  };
  security.pam.services.greetd.enableGnomeKeyring = true;

  services.xserver.displayManager.startx = {
    enable = true;
    generateScript = true;
  };

  environment.systemPackages = with pkgs; [
    swaynotificationcenter
    wofi
    wl-clipboard
    grim
    slurp
    wdisplays
    brightnessctl
    networkmanagerapplet
  ];
  programs.waybar.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [
      "keishis"
      "sandybox"
    ];
  };

  programs.xwayland.enable = true;
}
