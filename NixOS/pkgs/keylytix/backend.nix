{
  pkgs,
  keylytix,
  config,
  ...
}:
let
  keylytix-backend = pkgs.rustPlatform.buildRustPackage rec {
    pname = "keylytix-backend";
    version = "0.1.0";
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
    group = "sandi";
  };

  systemd.services."keylytix-backend" = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      EnvironmentFile = [ config.sops.secrets."keylytix-backend-env".path ];
      ExecStart = "${keylytix-backend}/bin/backend";
      User = "sandi";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8081 ];
}
