{ pkgs, keylytix, ... }:
let
  keylytix-frontend = pkgs.stdenv.mkDerivation rec {
    pname = "keylytix-frontend";
    version = "0.1.0";
    src = "${keylytix}/frontend";
    meta = {
      description = "Frontend of KeyLytix";
    };

    nativeBuildInputs = with pkgs; [
      nodejs_23
      yarn
      typescript
      yarnConfigHook
      yarnInstallHook
      yarnBuildHook
    ];
    yarnConfigHook = pkgs.yarnConfigHook;
    yarnInstallHook = pkgs.yarnInstallHook;
    yarnBuildHook = pkgs.yarnBuildHook;

    yarnOfflineCache = pkgs.fetchYarnDeps {
      yarnLock = "${src}/yarn.lock";
      hash = "sha256-AcYjIDMvoFcHcYvk5eS9LHnUanbqt8leuKlELs4kFQY=";
    };

    patchPhase = ''
      echo "export const API_URL=\"https://keylytix.app\";" > $PWD/env.prod.ts
    '';

    installPhase = ''
      mkdir -p $out
      cp -r dist/* $out/
    '';
  };
in
{
  system.activationScripts."keylytix-frontend" = ''
    cp -r ${keylytix-frontend}/* /nfs/keylytix/
  '';
}
