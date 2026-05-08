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
