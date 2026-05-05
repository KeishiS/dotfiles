{ ... }:
{
  services.gotify = {
    enable = true;
    environment = {
      GOTIFY_DATABASE_DIALECT = "sqlite3";
      GOTIFY_SERVER_PORT = 8111;
    };
  };

  networking.firewall.allowedTCPPorts = [ 8111 ];
}
