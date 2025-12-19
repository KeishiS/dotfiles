{ config, lib, ... }:
let
  connectDir = ./secrets;
  encFiles = lib.attrNames (builtins.readDir connectDir);

  removeEnc = name: lib.removeSuffix ".enc" name;
in
{
  sops.secrets = lib.listToAttrs (
    map (filename: {
      name = removeEnc filename;
      value = {
        format = "ini";
        sopsFile = connectDir + "/${filename}";
        mode = "0600";
      };
    }) encFiles
  );

  environment.etc = lib.listToAttrs (
    map (filename: {
      name = "NetworkManager/system-connections/${removeEnc filename}";
      value = {
        source = config.sops.secrets."${removeEnc filename}".path;
      };
    }) encFiles
  );
}
