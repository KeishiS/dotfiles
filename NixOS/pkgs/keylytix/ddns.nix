{ config, pkgs, ... }:
{
  sops.secrets."keylytix-ddns-env" = {
    format = "binary";
    sopsFile = ./secrets/ddns-env;
    mode = "400";
    owner = "sandi";
  };

  systemd.timers."keylytix-ddns" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "3m";
      OnUnitActiveSec = "15m";
      Unit = "keylytix-ddns.service";
    };
  };

  systemd.services."keylytix-ddns" = {
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
          RESP=$(curl -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" -H "Content-Type: application/json" -H "X-Auth-Email: $EMAIL" -H "Authorization: Bearer $API_TOKEN" -d '{ "name": "keylytix.app", "proxied": false, "type": "AAAA", "content": "'"$IPv6_ADDR"'" }')
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
        RESP=$(curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" -H "Content-Type: application/json" -H "X-Auth-Email: $EMAIL" -H "Authorization: Bearer $API_TOKEN" -d '{ "name": "keylytix.app", "proxied": false, "type": "AAAA", "content": "$IPv6_ADDR" }')
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
      EnvironmentFile = [ config.sops.secrets."keylytix-ddns-env".path ];
      Type = "oneshot";
      User = "sandi";
    };
  };
}
