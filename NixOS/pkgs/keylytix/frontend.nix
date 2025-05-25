{ pkgs, keylytix, ... }:
let
  keylytix-frontend = pkgs.stdenv.mkDerivation rec {
    pname = "keylytix-frontend";
    version = "0.2.0";
    src = "${keylytix}/frontend";
    meta = {
      description = "Frontend of KeyLytix";
    };

    nativeBuildInputs = with pkgs; [
      nodejs_24
      pnpm_10
      typescript
      pnpm_10.configHook
    ];

    pnpmDeps = pkgs.pnpm_10.fetchDeps {
      inherit pname version src;
      hash = "sha256-1iNNy4aKXTzCkL5LafBq3Q29MulRSYRVuQ1P3XeFYhE=";
    };

    patchPhase = ''
      echo "export const API_URL=\"https://keylytix.app\";" > $PWD/env.prod.ts
    '';

    buildPhase = ''
      runHook preBuild
      pnpm build
      runHook postBuild
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
