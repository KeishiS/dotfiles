{ config, pkgs, ... }:
{
  users.users.nginx.extraGroups = [ "acme" ];
  services.nginx = {
    enable = true;
    package = pkgs.nginxQuic;

    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedZstdSettings = true;

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
    format = "binary";
    sopsFile = ./secrets/sandi05-cloudflare-acme.enc;
    mode = "400";
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
  sops.secrets."sandi05-cloudflare-env" = {
    format = "binary";
    sopsFile = ./secrets/sandi05-cloudflare-env.enc;
    mode = "400";
    owner = "sandi";
  };

  systemd.timers."sandi05-cloudflare-ddns" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "3m";
      OnUnitActiveSec = "15m";
      Unit = "sandi05-cloudflare-ddns.service";
    };
  };

  systemd.services."sandi05-cloudflare-ddns" = {
    path = with pkgs; [
      curl
      gawk
      jq
      iproute2
    ];

    script = ''
      # 現在のipv6取得
      IPv6_ADDR=$(ip -6 addr show dev enp2s0 | awk '/inet6/ && /scope global/ && /dynamic/ && /mngtmpaddr/ {print $2}' | cut -d'/' -f1)

      # cloudflareの現在のAAAAレコード確認
      RECORDS=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" -H "Content-Type: application/json" -H "X-Auth-Email: $EMAIL" -H "Authorization: Bearer $API_TOKEN" | jq)

      RECORD_ID=$(echo $RECORDS | jq -r '.result[]' | jq -r 'select(.type=="AAAA")' | jq -r '.id')
      RECORD_NAME=$(echo $RECORDS | jq -r '.result[]' | jq -r 'select(.type=="AAAA")' | jq -r '.name')
      RECORD_CONTENT=$(echo $RECORDS | jq -r '.result[]' | jq -r 'select(.type=="AAAA")' | jq -r '.content')

      if [[ -n "$RECORD_ID" ]]; then
        if [[ "$RECORD_CONTENT" != "$IPv6_ADDR" ]]; then
          # Record IDがある場合は更新
          RESP=$(curl -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" -H "Content-Type: application/json" -H "X-Auth-Email: $EMAIL" -H "Authorization: Bearer $API_TOKEN" -d '{ "name": "*", "proxied": true, "ttl": 3600, "type": "AAAA", "content": "'"$IPv6_ADDR"'" }')
          echo $RESP
          if [[ $(echo $RESP | jq -r '.success') == "true" ]]; then
            # 更新成功
            echo "[INFO] SUCCESS to update an AAAA record: $IPv6_ADDR"
          else
            # 更新失敗
            echo "[ERROR] FAILED to update an AAAA record: $IPv6_ADDR"
          fi

        else
          # Record IDがあってもアドレスが変更されていない場合は何もしない
          echo "[INFO] nothing done"
        fi
      else
        # Record IDがない場合は新規追加
        RESP=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" -H "Content-Type: application/json" -H "X-Auth-Email: $EMAIL" -H "Authorization: Bearer $API_TOKEN" -d '{ "name": "*", "proxied": true, "ttl": 3600, "type": "AAAA", "content": "'"$IPv6_ADDR"'" }')
        echo $RESP
        if [[ $(echo $RESP | jq -r '.success') == "true" ]]; then
          # 新規追加成功
          echo "[INFO] SUCCESS to append an AAAA record: $IPv6_ADDR"
        else
          # 新規追加失敗
          echo "[ERROR] FAILED to append an AAAA record: $IPv6_ADDR"
        fi
      fi
    '';
    serviceConfig = {
      EnvironmentFile = [ config.sops.secrets."sandi05-cloudflare-env".path ];
      Type = "oneshot";
      User = "sandi";
    };
  };
}
