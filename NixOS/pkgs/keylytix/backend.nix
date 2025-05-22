{
  pkgs,
  keylytix,
  config,
  ...
}:
let
  keylytix-backend = pkgs.rustPlatform.buildRustPackage rec {
    pname = "keylytix-backend";
    version = "0.2.0";
    src = "${keylytix}/backend";
    cargoLock.lockFile = "${src}/Cargo.lock";

    buildInputs = [ pkgs.openssl ];
    nativeBuildInputs = [ pkgs.pkg-config ];
  };
in
{
  sops.secrets."keylytix-backend-env" = {
    format = "binary";
    sopsFile = ./secrets/backend-env;
    mode = "0400";
    owner = "sandi";
  };
  sops.secrets."pa.pem" = {
    format = "binary";
    sopsFile = ./secrets/ca.pem;
    mode = "0400";
    owner = "sandi";
  };

  systemd.services."keylytix-backend" = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    environment = {
      DB_SSL_PATH = config.sops.secrets."pa.pem".path;
    };
    serviceConfig = {
      EnvironmentFile = [ config.sops.secrets."keylytix-backend-env".path ];
      ExecStart = "${keylytix-backend}/bin/backend";
      User = "sandi";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8081 ];
}
