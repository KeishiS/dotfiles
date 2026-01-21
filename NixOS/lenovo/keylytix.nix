{
  config,
  pkgs,
  keylytix,
  ...
}:
let
  keylytixSrc = pkgs.stdenv.mkDerivation {
    name = "keylytix-src";
    src = keylytix;

    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      mkdir -p $out
      cp -r algorithm $out/
    '';
  };
in
{
  sops.secrets."keylytix/aws-access-key-id" = {
    sopsFile = ./secrets/keylytix.enc.yaml;
  };
  sops.secrets."keylytix/aws-secret-access-key" = {
    sopsFile = ./secrets/keylytix.enc.yaml;
  };

  systemd.services.keylytix-preprocess-worker = {
    enable = true;

    path = [ pkgs.python312 ];
    environment = {
      PYTHONUNBUFFERED = "1";
      PYTHONDONTWRITEBYTECODE = "1";

      UV_PYTHON_DOWNLOADS = "never";
      UV_SYSTEM_PYTHON = "true";
      UV_CACHE_DIR = "/var/cache/keylytix/uv";
      UV_PROJECT_ENVIRONMENT = "/var/lib/keylytix/.venv";
    };

    serviceConfig = {
      Type = "simple";
      Restart = "always";

      DynamicUser = true;
      StateDirectory = "keylytix";
      StateDirectoryMode = "0750";
      CacheDirectory = "keylytix";
      CacheDirectoryMode = "0750";

      LoadCredential = [
        "aws-access-key-id:${config.sops.secrets."keylytix/aws-access-key-id".path}"
        "aws-secret-access-key:${config.sops.secrets."keylytix/aws-secret-access-key".path}"
      ];

      WorkingDirectory = "${keylytixSrc}/algorithm/";
      # ExecStartPre = [ ];
      ExecStart = "${pkgs.uv}/bin/uv sync --frozen";
    };
  };
}
