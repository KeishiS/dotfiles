{ config, ... }:
{
  networking = {
    hostFiles = [
      "${config.sops.secrets.hosts.path}"
    ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
  };
}
