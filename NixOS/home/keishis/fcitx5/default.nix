{ lib, ... }:
{
  i18n.inputMethod = {
    fcitx5.settings = {
      inputMethod = {
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

  home.sessionVariables = {
    GTK_IM_MODULE = lib.mkForce "";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  gtk = {
    gtk2.extraConfig = ''
      gtk-im-module = fcitx
    '';
    gtk3.extraConfig.gtk-im-module = "fcitx";
    gtk4.extraConfig.gtk-im-module = "fcitx";
  };
}
