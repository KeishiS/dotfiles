{ lib, pkgs, ... }:
let
  b2TargetType = lib.types.submodule {
    options = {
      bucket = lib.mkOption {
        type = lib.types.str;
        description = "Backblaze B2 bucket name for this backup target.";
      };

      prefix = lib.mkOption {
        type = lib.types.str;
        description = "Backblaze B2 object prefix for this backup target.";
      };
    };
  };
in
{
  options.sandi.backup = {
    ageRecipients = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Common age recipients used for encrypted backup artifacts.";
    };

    b2 = {
      cliPackage = lib.mkOption {
        type = lib.types.package;
        default = pkgs.backblaze-b2;
        description = "Backblaze B2 CLI package used by backup jobs.";
      };

      targets = lib.mkOption {
        type = lib.types.attrsOf b2TargetType;
        default = { };
        description = "Backblaze B2 backup targets keyed by use case.";
      };
    };
  };
}
