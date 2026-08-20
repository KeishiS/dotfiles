{ ... }:
{
  nix = {
    settings = {
      max-jobs = "auto";
      cores = 0;

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      auto-optimise-store = true;

      substituters = [ "https://keishis.cachix.org" ];
      trusted-public-keys = [
        "keishis.cachix.org-1:j3UwGrrgTifYMa9Uo6fyDU8GEJBcorOzrHdkXBXruK4="
      ];
    };

    gc = {
      dates = "daily";
      options = "--delete-older-than 3d";
      automatic = true;
    };
  };

  programs.nix-ld.dev.enable = true;
  nixpkgs.config.allowUnfree = true;
}
