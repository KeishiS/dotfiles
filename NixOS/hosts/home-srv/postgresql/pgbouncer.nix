{ config, pkgs, ... }:
let
  certName = "db.sandi05.com";
  cert = config.security.acme.certs.${certName};

  appDatabases = [
    "keylytix_prod"
    "keylytix_dev"
    "koyomado_prod"
    "koyomado_dev"
  ];

  databaseConfig =
    database: "host=/run/postgresql port=5432 dbname=${database} max_db_connections=15";
in
{
  sops.secrets.postgresql-pgbouncer-users = {
    format = "binary";
    sopsFile = ./secrets/pgbouncer-users.enc.txt;
    mode = "0400";
    owner = "pgbouncer";
    group = "pgbouncer";
  };

  services.pgbouncer = {
    enable = true;
    openFirewall = true;

    settings = {
      databases = builtins.listToAttrs (
        map (database: {
          name = database;
          value = databaseConfig database;
        }) appDatabases
      );

      pgbouncer = {
        listen_addr = "localhost,192.168.100.24,100.112.172.58";
        listen_port = 6432;

        auth_type = "scram-sha-256";
        auth_file = config.sops.secrets.postgresql-pgbouncer-users.path;

        pool_mode = "transaction";
        max_client_conn = 200;
        default_pool_size = 10;
        reserve_pool_size = 5;
        reserve_pool_timeout = 5;
        server_idle_timeout = 600;
        server_lifetime = 3600;
        ignore_startup_parameters = "extra_float_digits";

        client_tls_sslmode = "require";
        client_tls_cert_file = "${cert.directory}/fullchain.pem";
        client_tls_key_file = "${cert.directory}/key.pem";
        client_tls_ca_file = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        server_tls_sslmode = "disable";
      };
    };
  };

  users.users.pgbouncer.extraGroups = [ "postgres" ];
}
