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
  services.xserver.displayManager.startx = {
    enable = true;
    generateScript = true;
  };

  services.greetd.settings.default_session.command = ''
    ${pkgs.tuigreet}/bin/tuigreet \
      --time \
      --asterisks \
      --remember-session \
      --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions \
      --xsessions ${config.services.displayManager.sessionData.desktops}/share/xsessions \
      --xsession-wrapper ${tuigreetXsessionWrapper}
  '';
}
