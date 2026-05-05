{ ... }:
{
  services.vikunja = {
    enable = true;
    frontendHostname = "tasks.sandi05.com";
    frontendScheme = "http";
  };

  networking.firewall.allowedTCPPorts = [ 3456 ];
}
