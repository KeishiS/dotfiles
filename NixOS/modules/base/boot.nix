{ ... }:
{
  boot.initrd.systemd.enable = true; # initrdでsystemdを使用(systemd-cryptenroll/FIDO2のため)
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 5;
    efi.canTouchEfiVariables = true;
  };
  boot.tmp.cleanOnBoot = true;
}
