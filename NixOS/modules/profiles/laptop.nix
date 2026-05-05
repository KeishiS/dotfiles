{ ... }:
{
  services.hardware.bolt.enable = true;
  services.logind.settings.Login.HandleLidSwitch = "suspend";
  boot.resumeDevice = ""; # ランダムswapを使っているためハイバネーション(resume)を無効化
}
