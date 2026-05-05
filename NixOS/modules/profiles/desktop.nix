{ lib, pkgs, ... }:
{
  programs.gnupg.agent = {
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  i18n.inputMethod = {
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
  environment.variables.GTK_IM_MODULE = lib.mkForce "";

  services.pcscd.enable = true;
  # YubiKeyが抜かれた際に画面ロック
  services.udev.extraRules = ''
    ACTION=="remove", ENV{ID_VENDOR_ID}=="1050", ENV{ID_MODEL_ID}=="0407", RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
  '';

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
        command = "${pkgs.tuigreet}/bin/tuigreet --time";
      };
    };
  };
  security.pam.services.greetd.enableGnomeKeyring = true;

  environment.systemPackages = with pkgs; [
    swaynotificationcenter
    wofi
    wl-clipboard
    grim
    slurp
    ghostty
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

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  programs.xwayland.enable = true;
}
