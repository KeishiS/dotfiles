{ pkgs, ... }:
{
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
    # font = "Lat2-Terminus16";
    keyMap = "jp106";
  };
  services.xserver = {
    xkb.layout = "jp";
    xkb.model = "jp106";
  };
}
