{ ... }:
{
  boot.initrd.systemd.enable = true; # initrdでsystemdを使用(systemd-cryptenroll/FIDO2のため)
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 5;
    efi.canTouchEfiVariables = true;
  };
  services.logind.settings.Login.HandleLidSwitch = "suspend"; # 蓋を閉じた際の挙動をsuspendに固定
  boot.resumeDevice = ""; # ランダムswapを使っているためハイバネーション(resume)を無効化
}
