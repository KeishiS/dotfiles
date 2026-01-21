{
  config,
  pkgs,
  lib,
  keylytix,
  uv2nix,
  pyproject-nix,
  build-system-pkgs,
  ...
}:
let
  workspace = uv2nix.lib.workspace.loadWorkspace {
    workspaceRoot = "${keylytix}/algorithm";
  };
  overlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
  };
  pythonSet =
    (pkgs.callPackage pyproject-nix.build.packages {
      python = pkgs.python312;
    }).overrideScope
      (
        lib.composeManyExtensions [
          build-system-pkgs.overlays.wheel
          overlay
        ]
      );
  preprocessWorkerEnv = pythonSet.mkVirtualEnv "preprocess-worker-env" {
    keylytix-preprocess = [ ];
  };

  optimizerWorkerEnv = pythonSet.mkVirtualEnv "optimizer-worker-env" {
    keylytix-optimizer = [ ];
  };

  commonServiceConfig = {
    Type = "simple";
    Restart = "always";
    DynamicUser = true;

    StateDirectoryMode = "0750";
    CacheDirectoryMode = "0750";

    LoadCredential = [
      "aws-credentials:${config.sops.secrets."keylytix/aws-credentials".path}"
      "aws-config:${config.sops.secrets."keylytix/aws-config".path}"
    ];
    Environment = [
      "AWS_SHARED_CREDENTIALS_FILE=%d/aws-credentials"
      "AWS_CONFIG_FILE=%d/aws-config"
    ];

    NoNewPrivileges = true;
    PrivateTmp = true;
    ProtectSystem = "strict";
    ProtectHome = true;
  };

  commonEnv = {
    PYTHONUNBUFFERED = "1";
    PYTHONDONTWRITEBYTECODE = "1";

    AWS_PROFILE = "default";
    LOG_LEVEL = "INFO";
    ENVIRONMENT = "prod";
  };
in
{
  sops.secrets."keylytix/aws-config" = {
    sopsFile = ./secrets/keylytix.enc.yaml;
    owner = "root";
    group = "root";
    mode = "0400";
    restartUnits = [
      "keylytix-preprocess-worker.target"
      "keylytix-optimizer-worker.target"
    ];
  };
  sops.secrets."keylytix/aws-credentials" = {
    sopsFile = ./secrets/keylytix.enc.yaml;
    owner = "root";
    group = "root";
    mode = "0400";
    restartUnits = [
      "keylytix-preprocess-worker.target"
      "keylytix-optimizer-worker.target"
    ];
  };

  systemd.services."keylytix-preprocess-worker@" = {
    description = "KeyLytix Preprocess Worker, instance %i";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    environment = commonEnv;
    serviceConfig = commonServiceConfig // {
      StateDirectory = "keylytix-preprocess";
      CacheDirectory = "keylytix-preprocess";
      ExecStart = "${preprocessWorkerEnv}/bin/preprocess-worker";
    };
  };

  systemd.targets.keylytix-preprocess-worker = {
    description = "KeyLytix Preprocess Worker (all instances)";
    wants = [
      "keylytix-preprocess-worker@1.service"
      "keylytix-preprocess-worker@2.service"
    ];
    wantedBy = [ "multi-user.target" ];
  };

  systemd.services."keylytix-optimizer-worker@" = {
    description = "KeyLytix Optimizer Worker, instance %i";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    environment = commonEnv;
    serviceConfig = commonServiceConfig // {
      StateDirectory = "keylytix-optimizer";
      CacheDirectory = "keylytix-optimizer";
      ExecStart = "${optimizerWorkerEnv}/bin/optimizer-worker";
    };
  };

  systemd.targets.keylytix-optimizer-worker = {
    description = "KeyLytix Optimizer Worker (all instances)";
    wants = [
      "keylytix-optimizer-worker@1.service"
      "keylytix-optimizer-worker@2.service"
    ];
    wantedBy = [ "multi-user.target" ];
  };
}
