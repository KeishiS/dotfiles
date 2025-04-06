{ ... }:
{
  services.nginx = {
    enable = true;
    virtualHosts."sandi05.com" = {
      serverName = "sandi05.com";
      root = "/var/www";
      listen = [
        {
          addr = "0.0.0.0";
          port = 443;
        }
        {
          addr = "[::]";
          port = 443;
        }
      ];
      ssl = true;
    };

    virtualHosts."sandi05.com-redirect" = {
      serverName = "sandi05.com";
      listen = [
        {
          addr = "0.0.0.0";
          port = 80;
        }
        {
          addr = "[::]";
          port = 443;
        }
      ];
      extraConfig = ''
        return 301 https://$host$request_uri;
      '';
    };
  };

  security.acme = {
    acceptTerms = true;
    email = "nobuta05@gmail.com";
    certs."sandi05.com" = {
      webroot = "/var/lib/acme";
      postRun = "systemctl reload nginx";
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
