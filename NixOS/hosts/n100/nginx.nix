{ config, pkgs, ... }:
{
  users.users.nginx.extraGroups = [ "acme" ];
  services.nginx = {
    enable = true;

    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

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
      quic = true;
      http3 = true;
      extraConfig = ''
        add_header Alt-Svc 'h3=":443"; ma=86400';
      '';

      locations."/" = {
        extraConfig = ''
          client_max_body_size 2G;
          proxy_read_timeout    3600s;
          proxy_send_timeout    3600s;
          proxy_connect_timeout 3600s;
          send_timeout          3600s;
        '';
        proxyPass = "http://calc-serv.sandi05.com:80";
        proxyWebsockets = true;
      };
    };

    #---------------------------------------------------------------------
    # Kanidm
    # --------------------------------------------------------------------
    virtualHosts."id.sandi05.com-redirect" = {
      serverName = "id.sandi05.com";
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

    virtualHosts."id.sandi05.com" = {
      serverName = "id.sandi05.com";
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
      quic = true;
      http3 = true;
      extraConfig = ''
        add_header Alt-Svc 'h3=":443"; ma=86400';
      '';

      locations."/" = {
        proxyPass = "https://192.168.100.20:443";
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Connection "";

          proxy_ssl_server_name on;
          proxy_ssl_name id.sandi05.com;
          proxy_ssl_verify on;
          proxy_ssl_verify_depth 5;
          proxy_ssl_trusted_certificate ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt;
        '';
      };
    };

    #---------------------------------------------------------------------
    # VaultWarden
    # --------------------------------------------------------------------
    virtualHosts."key.sandi05.com-redirect" = {
      serverName = "key.sandi05.com";
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

    virtualHosts."key.sandi05.com" = {
      serverName = "key.sandi05.com";
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
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $connection_upgrade;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $http_host;
        '';
        proxyPass = "http://lenovo.sandi05.com:8000";
      };
      locations."/notifications/hub" = {
        proxyPass = "http://lenovo.sandi05.com:8000";
        proxyWebsockets = true;
      };
      locations."/notifications/hub/negotiate" = {
        proxyPass = "http://lenovo.sandi05.com:8000";
      };
    };

    #---------------------------------------------------------------------
    # Jellyfin
    # --------------------------------------------------------------------
    virtualHosts."stream.sandi05.com-redirect" = {
      serverName = "stream.sandi05.com";
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

    virtualHosts."stream.sandi05.com" = {
      serverName = "stream.sandi05.com";
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
        proxyPass = "http://lenovo.sandi05.com:8096";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_read_timeout    3600s;
          proxy_send_timeout    3600s;
        '';
      };
    };

    #---------------------------------------------------------------------
    # Leantime
    # --------------------------------------------------------------------
    virtualHosts."project.sandi05.com-redirect" = {
      serverName = "project.sandi05.com";
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

    virtualHosts."project.sandi05.com" = {
      serverName = "project.sandi05.com";
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
        proxyPass = "http://lenovo.sandi05.com:80";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 256M;
          proxy_read_timeout 3600s;
          proxy_send_timeout 3600s;
        '';
      };
    };

    #---------------------------------------------------------------------
    # TriliumNext
    # --------------------------------------------------------------------
    virtualHosts."notes.sandi05.com-redirect" = {
      serverName = "notes.sandi05.com";
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

    virtualHosts."notes.sandi05.com" = {
      serverName = "notes.sandi05.com";
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
        proxyPass = "http://lenovo.sandi05.com:80";
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 0;
          proxy_buffer_size 128k;
          proxy_buffers 4 256k;
          proxy_busy_buffers_size 256k;
          proxy_read_timeout 3600s;
        '';
      };
    };

    # Only the OIDC-protected vMCP endpoint and its RFC 9728 discovery
    # documents are forwarded. ToolHive's management API is never exposed.
    virtualHosts."mcp.sandi05.com-redirect" = {
      serverName = "mcp.sandi05.com";
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

    virtualHosts."mcp.sandi05.com" = {
      serverName = "mcp.sandi05.com";
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
      locations."= /mcp" = {
        proxyPass = "http://lenovo.sandi05.com:80/mcp";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          proxy_read_timeout 3600s;
          proxy_send_timeout 3600s;
        '';
      };
      locations."= /.well-known/oauth-protected-resource" = {
        proxyPass = "http://lenovo.sandi05.com:80/.well-known/oauth-protected-resource";
      };
      locations."= /.well-known/oauth-protected-resource/mcp" = {
        proxyPass = "http://lenovo.sandi05.com:80/.well-known/oauth-protected-resource/mcp";
      };
      locations."/".return = "404";
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
        "storage.sandi05.com"
        "id.sandi05.com"
        "key.sandi05.com"
        "stream.sandi05.com"
        "project.sandi05.com"
        "notes.sandi05.com"
        "mcp.sandi05.com"
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
}
