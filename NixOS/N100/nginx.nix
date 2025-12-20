{ config, ... }:
{
  users.users.nginx.extraGroups = [ "acme" ];
  services.nginx = {
    enable = true;

    recommendedTlsSettings = true;
    recommendedGzipSettings = true;

    #---------------------------------------------------------------------
    # Plex
    # --------------------------------------------------------------------
    virtualHosts."video.sandi05.com-redirect" = {
      serverName = "video.sandi05.com";
      listen = [
        {
          addr = "0.0.0.0";
          port = 80;
        }
        {
          addr = "[::]";
          port = 80;
        }
      ];

      extraConfig = ''
        return 301 https://$host$request_uri;
      '';
    };

    virtualHosts."video.sandi05.com" = {
      serverName = "video.sandi05.com";
      listen = [
        {
          addr = "0.0.0.0";
          port = 443;
          ssl = true;
        }
        {
          addr = "[::]";
          port = 443;
          ssl = true;
        }
      ];
      addSSL = true;
      useACMEHost = "sandi05.com";

      locations."/" = {
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $http_host;

          proxy_buffering off;
        '';
        proxyPass = "http://192.168.10.17:32400";
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
          proxy_set_header X-Forwarded-Host $http_host;
        '';
        proxyPass = "http://192.168.10.17:32400";
      };
    };

    #---------------------------------------------------------------------
    # Nextcloud
    # --------------------------------------------------------------------
    virtualHosts."storage.sandi05.com-redirect" = {
      serverName = "storage.sandi05.com";
      listen = [
        {
          addr = "0.0.0.0";
          port = 80;
        }
        {
          addr = "[::]";
          port = 80;
        }
      ];
      extraConfig = ''
        return 301 https://$host$request_uri;
      '';
    };

    virtualHosts."storage.sandi05.com" = {
      serverName = "storage.sandi05.com";
      listen = [
        {
          addr = "0.0.0.0";
          port = 443;
          ssl = true;
        }
        {
          addr = "[::]";
          port = 443;
          ssl = true;
        }
      ];
      addSSL = true;
      useACMEHost = "sandi05.com";

      http2 = true;
      http3 = true;

      locations."/" = {
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_buffering off;

          client_max_body_size 2G;
          proxy_read_timeout    3600s;
          proxy_send_timeout    3600s;
          proxy_connect_timeout 3600s;
          send_timeout          3600s;
        '';
        proxyPass = "http://192.168.10.17";
        proxyWebsockets = true;
      };
    };

    #---------------------------------------------------------------------
    # Gotify
    # --------------------------------------------------------------------
    virtualHosts."notify.sandi05.com-redirect" = {
      serverName = "notify.sandi05.com";
      listen = [
        {
          addr = "0.0.0.0";
          port = 80;
        }
        {
          addr = "[::]";
          port = 80;
        }
      ];
      extraConfig = ''
        return 301 https://$host$request_uri;
      '';
    };

    virtualHosts."notify.sandi05.com" = {
      serverName = "notify.sandi05.com";
      listen = [
        {
          addr = "0.0.0.0";
          port = 443;
          ssl = true;
        }
        {
          addr = "[::]";
          port = 443;
          ssl = true;
        }
      ];
      addSSL = true;
      useACMEHost = "sandi05.com";

      locations."/" = {
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $http_host;
          proxy_buffering off;
        '';
        proxyPass = "http://192.168.10.17:8111";
        proxyWebsockets = true;
      };
    };

    #---------------------------------------------------------------------
    # Root
    # --------------------------------------------------------------------
    virtualHosts."sandi05.com-redirect" = {
      serverName = "sandi05.com";
      listen = [
        {
          addr = "0.0.0.0";
          port = 80;
        }
        {
          addr = "[::]";
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
        {
          addr = "[::]";
          port = 443;
          ssl = true;
        }
      ];
      addSSL = true;
      useACMEHost = "sandi05.com";
    };
  };

  sops.secrets."sandi05-cloudflare-acme" = {
    format = "yaml";
    sopsFile = ./secrets/sandi05-cloudflare.enc.yaml;
    mode = "0400";
    owner = "acme";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "nobuta05@gmail.com";

    certs."sandi05.com" = {
      domain = "sandi05.com";
      extraDomainNames = [
        "video.sandi05.com"
        "storage.sandi05.com"
        "notify.sandi05.com"
      ];
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets."sandi05-cloudflare-acme".path;
      dnsPropagationCheck = true;
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ 443 ];

  #---------------------------------------------------------------------
  # DDNS for IPv6
  #---------------------------------------------------------------------
  sops.secrets."cloudflare-ddns-token" = {
    format = "yaml";
    sopsFile = ./secrets/sandi05-cloudflare.enc.yaml;
    mode = "0400";
  };
  services.ddclient = {
    enable = true;
    protocol = "cloudflare";
    username = "token";
    passwordFile = config.sops.secrets."cloudflare-ddns-token".path;
    zone = "sandi05.com";
    domains = [ "sandi05.com" ];
    usev6 = "webv6, web=googlev6";
  };
}
