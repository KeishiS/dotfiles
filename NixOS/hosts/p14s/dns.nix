{ config, pkgs, ... }:
let
  dnsFailoverScript = pkgs.replaceVarsWith {
    src = ./scripts/dns-failover.sh;
    name = "dns-failover.sh";
    isExecutable = true;

    replacements = {
      dbDomainFile = config.sops.secrets.db_domain.path;
      upstreamDnsFile = config.sops.secrets.upstream_dns.path;
      dbFallbackIpFile = config.sops.secrets.fallback_ip.path;
      fixedIpFile = config.sops.secrets.fixed_ip.path;
    };
  };
in
{
  sops.secrets = {
    db_domain = {
      sopsFile = ./secrets/dns.enc.yaml;
    };
    upstream_dns = {
      sopsFile = ./secrets/dns.enc.yaml;
    };
    fallback_ip = {
      sopsFile = ./secrets/dns.enc.yaml;
    };
    fixed_ip = {
      sopsFile = ./secrets/dns.enc.yaml;
    };
  };

  services.dnsmasq = {
    enable = true;
    settings.addn-hosts = [ "etc/dnsmasq-hosts/db-override.hosts" ];
  };

  system.activationScripts.dbDnsHosts = {
    deps = [ "setupSecrets" ];
    text = ''
      mkdir -p /etc/dnsmasq-hosts
      if [ ! -f /etc/dnsmasq-hosts/db-override.hosts ]; then
        FALLBACK_IP=$(cat ${config.sops.secrets.fallback_ip.path})
        DOMAIN=$(cat ${config.sops.secrets.db_domain.path})
        echo "$FALLBACK_IP $DOMAIN" > /etc/dnsmasq-hosts/db-override.hosts
      fi
    '';
  };

  systemd.services.dns-failover = {
    description = "DB DNS failover check";
    after = [ "run-secrets.d.mount" ];
    requires = [ "run-secrets.d.mount" ];
    path = with pkgs; [
      dnsutils
      netcat
      procps
      util-linux
      gnugrep
      gawk
    ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = dnsFailoverScript;
    };
  };

  systemd.timers.dns-failover = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10s";
      OnUnitActiveSec = "30s";
      AccuracySec = "1s";
    };
  };
}
