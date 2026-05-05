{
  config,
  keylytix,
  pkgs,
  ...
}:
let
  servName = "keylytix";
  src = "${keylytix}/backend";
  keylytix-backend = pkgs.rustPlatform.buildRustPackage {
    pname = "keylytix-backend";
    version = "0.1.0";
    inherit src;
    cargoLock.lockFile = "${src}/Cargo.lock";
    cargoBuildFlags = [
      "--package"
      "graphql-gateway"
      "--package"
      "auth-service"
      "--package"
      "user-query-service"
      "--package"
      "user-command-service"
    ];
    nativeBuildInputs = with pkgs; [
      protobuf
      buf
    ];
  };

  commonEnv = {
    STAGE = "prod";
    AWS_PROFILE = servName;
  };

  commonServiceCfg = {
    User = servName;
    Group = servName;

    NoNewPrivileges = true;
    PrivateTmp = true;
    ProtectSystem = "strict";
    ProtectHome = true;

    LoadCredential = [
      "aws-credentials:${config.sops.secrets."aws/credentials".path}"
      "aws-config:${config.sops.secrets."aws/config".path}"
    ];
    Environment = [
      "AWS_SHARED_CREDENTIALS_FILE=%d/aws-credentials"
      "AWS_CONFIG_FILE=%d/aws-config"
    ];
  };
in
{
  imports = [
    ./db.nix
    ./pool.nix
    ./monitoring
  ];

  users.groups.${servName} = { };
  users.users.${servName} = {
    isSystemUser = true;
    group = servName;
    home = "/var/lib/${servName}";
    createHome = true;
  };

  sops.secrets."aws/config" = {
    sopsFile = ./secrets/credentials.enc.yml;
    format = "yaml";
    owner = servName;
    group = servName;
    mode = "0400";
  };

  sops.secrets."aws/credentials" = {
    sopsFile = ./secrets/credentials.enc.yml;
    format = "yaml";
    owner = servName;
    group = servName;
    mode = "0400";
  };

  #--------------------------------------
  # auth-service
  # -------------------------------------
  systemd.services."${servName}-auth-service@" = {
    description = "${servName} Authentication Service, instance %i";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    environment = commonEnv // {
      INSTANCE = "%i";
    };

    serviceConfig = commonServiceCfg // {
      ExecStart = pkgs.writeShellScript "auth-service.sh" ''
        AUTH_SERVICE_PORT=$(( 51000 + $INSTANCE )) ${keylytix-backend}/bin/auth-service
      '';
    };
  };

  systemd.targets."${servName}-auth-service" = {
    description = "${servName} Authentication Services (all instances)";
    wants = [
      "${servName}-auth-service@1.service"
      "${servName}-auth-service@2.service"
    ];
    wantedBy = [ "multi-user.target" ];
  };

  #--------------------------------------
  # user-query-service
  # -------------------------------------
  systemd.services."${servName}-user-query-service@" = {
    description = "${servName} User Query Service, instance %i";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    environment = commonEnv // {
      INSTANCE = "%i";
    };

    serviceConfig = commonServiceCfg // {
      ExecStart = pkgs.writeShellScript "user-query-service.sh" ''
        USER_QUERY_SERVICE_PORT=$(( 52000 + $INSTANCE )) ${keylytix-backend}/bin/user-query-service
      '';
    };
  };

  systemd.targets."${servName}-user-query-service" = {
    description = "${servName} User Query Services (all instances)";
    wants = [
      "${servName}-user-query-service@1.service"
      "${servName}-user-query-service@2.service"
    ];
    wantedBy = [ "multi-user.target" ];

    after = [ "pgbouncer.service" ];
    requires = [ "pgbouncer.service" ];
  };

  #--------------------------------------
  # user-command-service
  # -------------------------------------
  systemd.services."${servName}-user-command-service@" = {
    description = "${servName} User Command Service, instance %i";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    environment = commonEnv // {
      INSTANCE = "%i";
      AUTH_SERVICE_ENDPOINT = "http://localhost:51000";
    };

    serviceConfig = commonServiceCfg // {
      ExecStart = pkgs.writeShellScript "user-command-service.sh" ''
        USER_COMMAND_SERVICE_PORT=$(( 53000 + $INSTANCE )) ${keylytix-backend}/bin/user-command-service
      '';
    };
  };

  systemd.targets."${servName}-user-command-service" = {
    description = "${servName} User Command Services (all instances)";
    wants = [
      "${servName}-user-command-service@1.service"
      "${servName}-user-command-service@2.service"
    ];
    wantedBy = [ "multi-user.target" ];

    after = [
      "${servName}-auth-service.target"
      "pgbouncer.service"
    ];
    requires = [
      "${servName}-auth-service.target"
      "pgbouncer.service"
    ];
  };

  #--------------------------------------
  # graphql-gateway
  # -------------------------------------
  systemd.services."${servName}-graphql-gateway@" = {
    description = "${servName} GraphQL Gateway, instance %i";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    environment = commonEnv // {
      INSTANCE = "%i";
      AUTH_SERVICE_ENDPOINT = "http://localhost:51000";
      USER_QUERY_SERVICE_ENDPOINT = "http://localhost:52000";
      USER_COMMAND_SERVICE_ENDPOINT = "http://localhost:53000";
    };

    serviceConfig = commonServiceCfg // {
      ExecStart = pkgs.writeShellScript "graphql-gateway.sh" ''
        GRAPHQL_GATEWAY_PORT=$(( 50000 + $INSTANCE )) ${keylytix-backend}/bin/graphql-gateway
      '';
    };
  };

  systemd.targets."${servName}-graphql-gateway" = {
    description = "${servName} GraphQL Gateways (all instances)";
    wants = [
      "${servName}-graphql-gateway@1.service"
      "${servName}-graphql-gateway@2.service"
    ];
    wantedBy = [ "multi-user.target" ];

    after = [
      "${servName}-auth-service.target"
      "${servName}-user-query-service.target"
      "${servName}-user-command-service.target"
    ];
    requires = [
      "${servName}-auth-service.target"
      "${servName}-user-query-service.target"
      "${servName}-user-command-service.target"
    ];
  };
}
