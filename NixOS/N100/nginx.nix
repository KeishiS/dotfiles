{ config, my-secrets, ... }:
{
  age.secrets = {
    htpasswd = {
      file = "${my-secrets}/htpasswd.age";
      path = "/run/ragenix/htpasswd";
      mode = "0400";
      owner = "nginx";
      group = "nginx";
    };
  };

  services.nginx = {
    enable = true;

    virtualHosts."sandi05.com-redirect" = {
      serverName = "sandi05.com";
      listen = [
        {
          addr = "0.0.0.0";
          port = 80;
        }
      ];
      extraConfig = ''
        return 301 https://$host$request_uri;
      '';
    };

    virtualHosts."sandi05.com" = {
      serverName = "sandi05.com";
      root = "/var/www";
      listen = [
        {
          addr = "0.0.0.0";
          port = 443;
          ssl = true;
        }
      ];
      addSSL = true;
      enableACME = true;
    };

    virtualHosts."video.sandi05.com" = {
      serverName = "video.sandi05.com";
      listen = [
        {
          addr = "0.0.0.0";
          port = 443;
          ssl = true;
        }
      ];
      addSSL = true;
      enableACME = true;
      # basicAuthFile = config.age.secrets.htpasswd.path;

      locations."/" = {
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Protocol $scheme;
          proxy_set_header X-Forwarded-Host $http_host;

          proxy_buffering off;
        '';
        proxyPass = "http://192.168.10.17:8096";
      };

      locations."/socket" = {
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Protocol $scheme;
          proxy_set_header X-Forwarded-Host $http_host;
        '';
        proxyPass = "https://192.168.10.17:8096";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "nobuta05@gmail.com";
    defaults.postRun = "systemctl reload nginx";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
