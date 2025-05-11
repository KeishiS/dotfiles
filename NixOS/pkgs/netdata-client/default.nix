{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  services.netdata = {
    enable = true;
    config = {
      global = {
        "memory mode" = "ram";
        timezone = "Asia/Tokyo";
      };
      plugins."go.d" = "yes";
    };
    configDir."stream.conf" = pkgs.writeText "stream.conf" ''
      [stream]
        enabled = yes
        destination = nixos-sandi-lenovo
        api key = 493e294a-1bcc-45c1-bdd3-e82b8dbc5ff9
    '';
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
