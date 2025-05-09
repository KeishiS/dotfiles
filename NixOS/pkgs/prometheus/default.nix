{ ... }:
{
  networking.firewall.allowedTCPPorts = [ 9090 ];
  services.prometheus = {
    enable = true;
  };
}
