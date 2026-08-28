{
  config,
  pkgs,
  ...
}:
{
  users.users.nginx.extraGroups = [ "acme" ];
  services.nginx = {
    enable = true;

    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    # KoyomadoのOTPメールが連投されないよう、ログイン要求だけ流量を絞る。
    # Cloudflareのproxy越しでは$binary_remote_addrがCloudflareのIPになるため、
    # 利用者ごとに数えられるようCF-Connecting-IPがあればそれを鍵にする。
    appendHttpConfig = ''
      map $http_cf_connecting_ip $koyomado_client_ip {
        ""      $binary_remote_addr;
        default $http_cf_connecting_ip;
      }
      limit_req_zone $koyomado_client_ip zone=koyomado_login:1m rate=6r/m;
    '';

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
    # Marginalis
    # --------------------------------------------------------------------
    virtualHosts."marginalis.sandi05.com-redirect" = {
      serverName = "marginalis.sandi05.com";
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

    virtualHosts."marginalis.sandi05.com" = {
      serverName = "marginalis.sandi05.com";
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
        proxyPass = "http://lenovo.sandi05.com:3456";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-Host $host;

          client_max_body_size 256M;
          proxy_read_timeout 3600s;
          proxy_send_timeout 3600s;
        '';
      };
    };

    #---------------------------------------------------------------------
    # Renkan
    # --------------------------------------------------------------------
    virtualHosts."renkan.sandi05.com-redirect" = {
      serverName = "renkan.sandi05.com";
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

    virtualHosts."renkan.sandi05.com" = {
      serverName = "renkan.sandi05.com";
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
      locations."/".proxyPass = "http://calc-serv.sandi05.com:6789/";
    };

    #---------------------------------------------------------------------
    # Koyomado
    # --------------------------------------------------------------------
    virtualHosts."koyomado.com-redirect" = {
      serverName = "koyomado.com";
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

    virtualHosts."koyomado.com" = {
      serverName = "koyomado.com";
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
      useACMEHost = "koyomado.com";

      # Web UIとAPIは同一originで、calc-servのkoyomado.serviceが両方を返す。
      locations."/".proxyPass = "http://calc-serv.sandi05.com:8080";

      locations."/api/auth/request-login" = {
        proxyPass = "http://calc-serv.sandi05.com:8080";
        extraConfig = ''
          limit_req zone=koyomado_login burst=3 nodelay;
        '';
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

  sops.secrets.koyomado-cloudflare-acme = {
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
        "renkan.sandi05.com"
        "marginalis.sandi05.com"
      ];
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets."sandi05-cloudflare-acme".path;
      dnsPropagationCheck = true;
    };

    # Koyomadoはzoneが別のため証明書も分ける。DNS-01で取得するので、環境変数の
    # Cloudflare tokenにkoyomado.com zoneのZone:ReadとDNS:Editが必要になる。
    certs."koyomado.com" = {
      domain = "koyomado.com";
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets.koyomado-cloudflare-acme.path;
      dnsPropagationCheck = true;
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ 443 ];
}
