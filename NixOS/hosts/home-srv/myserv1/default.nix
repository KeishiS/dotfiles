{
  config,
  koyomado,
  pkgs,
  ...
}:
let
  servName = "koyomado-dev";
  src = "${koyomado}/backend";
  cargoToml = builtins.fromTOML (builtins.readFile "${src}/Cargo.toml");

  koyomado-backend = pkgs.rustPlatform.buildRustPackage {
    pname = "koyomado-backend";
    version = cargoToml.package.version;
    inherit src;

    cargoLock.lockFile = "${src}/Cargo.lock";
    cargoBuildFlags = [
      "--no-default-features"
      "--features"
      "gcp"
    ];
    cargoCheckFlags = [
      "--no-default-features"
      "--features"
      "gcp"
    ];
  };

  backendEnv = {
    BIND_ADDR = "127.0.0.1:8808";
    KOYOMADO_STAGE = "dev";
    CONFIG_SOURCE = "gcp";
    AUTH_PROVIDER = "gcp-identity-platform";
    GCP_PROJECT_ID = "koyomado-dev";
    GCP_PARAMETER_LOCATION = "global";
    GCP_PARAMETER_VERSION = "v1";
    CORS_ALLOWED_ORIGINS = "https://dev.koyomado.com";
    AUTH_EMAIL_LINK_CONTINUE_URL = "https://dev.koyomado.com/login";
    AUTH_COOKIE_SECURE = "true";
    RUST_LOG = "info";
  };

  backendStart = pkgs.writeShellScript "koyomado-dev-backend.sh" ''
    set -eu
    export GOOGLE_APPLICATION_CREDENTIALS="$CREDENTIALS_DIRECTORY/gcp-service-account.json"
    exec ${koyomado-backend}/bin/koyomado-backend
  '';

  commonServiceCfg = {
    User = servName;
    Group = servName;

    NoNewPrivileges = true;
    PrivateTmp = true;
    ProtectSystem = "strict";
    ProtectHome = true;
    RestrictSUIDSGID = true;
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
  };
in
{
  imports = [
    ./tunnel.nix
  ];
  users.groups.${servName} = { };
  users.users.${servName} = {
    isSystemUser = true;
    group = servName;
    home = "/var/lib/${servName}";
    createHome = true;
  };

  sops.secrets.koyomado-dev-backend = {
    sopsFile = ./secrets/dev-backend.enc.json;
    format = "json";
    owner = servName;
    group = servName;
    key = "";
    mode = "0400";
  };

  systemd.services."${servName}-backend" = {
    description = "Koyomado dev backend";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = backendEnv;

    serviceConfig = commonServiceCfg // {
      ExecStart = backendStart;
      LoadCredential = [
        "gcp-service-account.json:${config.sops.secrets.koyomado-dev-backend.path}"
      ];
      Restart = "on-failure";
      RestartSec = "5s";
      StateDirectory = servName;
      WorkingDirectory = "/var/lib/${servName}";
    };
  };
}
