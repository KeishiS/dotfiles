{ pkgs, ... }:
{
  services.pcscd.enable = true;

  # YubiKeyが抜かれた際に画面ロック
  services.udev.extraRules = ''
    ACTION=="remove", ENV{ID_VENDOR_ID}=="1050", ENV{ID_MODEL_ID}=="0407", RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
  '';
}
