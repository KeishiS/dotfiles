{ config, ... }:
{
  sops.secrets.pgbouncer-users = {
    sopsFile = ./secrets/users.enc.txt;
    format = "binary";
    owner = "pgbouncer";
    group = "pgbouncer";
    mode = "0400";
  };

  services.pgbouncer = {
    enable = true;
    openFirewall = true;

    settings = {
      databases = {
        keylytix_prod = "host=/run/postgresql dbname=keylytix_prod user=prod_ro";
        keylytix_dev = "host=/run/postgresql dbname=keylytix_dev user=dev_ro";
      };

      users = {
        prod_ro = "pool_mode=transaction";
        dev_ro = "pool_mode=transaction";
      };

      pgbouncer = {
        pool_mode = "transaction";
        listen_addr = "db.sandi05.com,127.0.0.1,192.168.10.4,192.168.10.10,::1";
        listen_port = 6432;
        unix_socket_dir = "/run/pgbouncer";
        auth_type = "scram-sha-256";
        auth_file = config.sops.secrets.pgbouncer-users.path;
        admin_users = "pgbouncer_admin";
        stats_users = "pgbouncer_stats";
        ignore_startup_parameters = "extra_float_digits";
      };
    };
  };
}
