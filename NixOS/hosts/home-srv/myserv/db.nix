{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../../../modules/services/cloudflare
  ];
  security.acme = {
    acceptTerms = true;
    useRoot = true;
    defaults.email = "nobuta05@gmail.com";

    certs."db.sandi05.com" = {
      domain = "db.sandi05.com";
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets."sandi05-cloudflare-acme".path;
      dnsPropagationCheck = true;
      group = "postgres";
    };
  };

  sops.secrets.pg_service = {
    format = "binary";
    sopsFile = ./secrets/pg_service.enc.conf;
    owner = "postgres";
    group = "postgres";
    mode = "0400";
    path = "/var/lib/postgresql/18/pg_service.conf";
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;
    checkConfig = true;
    enableTCPIP = true;

    extensions =
      ps: with ps; [
        pgvector
      ];

    settings = {
      ssl = true;
      ssl_cert_file = "/var/lib/acme/db.sandi05.com/fullchain.pem";
      ssl_key_file = "/var/lib/acme/db.sandi05.com/key.pem";

      listen_addresses = lib.mkForce "localhost,db.sandi05.com,192.168.10.4,192.168.10.10,100.85.14.63,[::1]";
      logging_collector = true;
      log_connections = true;
      log_disconnections = true;
      log_line_prefix = "%m [%p] %q%u@%d ";
      password_encryption = "scram-sha-256";

      max_connections = 100;
      max_worker_processes = 4;
      max_logical_replication_workers = 4;
      max_sync_workers_per_subscription = 2;
      reserved_connections = 3;
      superuser_reserved_connections = 3;

      unix_socket_directories = "/run/postgresql";
    };
    authentication = lib.mkForce ''
      local all postgres peer
      local all all scram-sha-256
      host all all 127.0.0.1/32 scram-sha-256
      host all all ::1/128 scram-sha-256
      hostssl all all 192.168.10.0/24 scram-sha-256
      hostssl all all 100.117.41.56/32 scram-sha-256
    '';
  };

  networking.firewall.allowedTCPPorts = [ 5432 ];
}
