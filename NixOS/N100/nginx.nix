{ config, pkgs, ... }:
{
  services.nginx = {
    enable = true;

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
      locations."/.well-known/acme-challenge/" = {
        alias = "/var/lib/acme/acme-challenge/.well-known/acme-challenge/";
      };
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
      enableACME = true;
    };

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
      locations."/.well-known/acme-challenge/" = {
        alias = "/var/lib/acme/acme-challenge/.well-known/acme-challenge/";
      };
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
      enableACME = true;

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
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "nobuta05@gmail.com";
    defaults.postRun = "systemctl reload nginx";
    defaults.dnsPropagationCheck = true;
    certs."sandi05.com".email = "nobuta05@gmail.com";
    certs."video.sandi05.com".email = "nobuta05@gmail.com";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

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
          RESP=$(curl -X PATCH "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" -H "Content-Type: application/json" -H "X-Auth-Email: $EMAIL" -H "Authorization: Bearer $API_TOKEN" -d '{ "name": "sandi05.com", "proxied": false, "type": "AAAA", "content": "'"$IPv6_ADDR"'" }')
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
        RESP=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" -H "Content-Type: application/json" -H "X-Auth-Email: $EMAIL" -H "Authorization: Bearer $API_TOKEN" -d '{ "name": "sandi05.com", "proxied": false, "type": "AAAA", "content": "'"$IPv6_ADDR"'" }')
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
