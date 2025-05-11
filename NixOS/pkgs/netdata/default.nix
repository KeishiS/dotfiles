{ config, pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [
    19999
    8125 # for metric
    8126 # for metric
  ];
  nixpkgs.config.allowUnfree = true;

  services.netdata = {
    enable = true;
    package = pkgs.netdata.override { withCloudUi = true; };
    config = {
      global = {
        "bind to" = "*";
        timezone = "Asia/Tokyo";
      };
      plugins."go.d" = "yes";
    };
    configDir."stream.conf" = config.sops.secrets."stream.conf".path;
  };
  sops.secrets."stream.conf" = {
    format = "ini";
    sopsFile = ./secrets/stream.enc.ini;
    mode = "0440";
    owner = "netdata";
    group = "netdata";
  };

  systemd.services.netdata = {
    path = [ "/run/wrappers" ];
    serviceConfig.CapabilityBoundingSet = "CAP_SYS_RAWIO";
  };

  environment.etc."netdata/go.d.conf".text = ''
    enabled: yes
    default_run: yes
    max_procs: 1
    modules:
      smartctl: yes
  '';
  environment.etc."netdata/go.d/smartctl.conf".text = ''
    update_every: 60
    scan_every: 600
    poll_devices_every: 3600
    jobs:
      - name: smartctl
  '';

  environment.systemPackages = [ pkgs.smartmontools ];
  security.wrappers.smartctl = {
    source = "${pkgs.smartmontools}/bin/smartctl";
    capabilities = "cap_dac_override,cap_sys_rawio+ep";
    owner = "root";
    group = "root";
  };
}
