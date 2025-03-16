{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    ragenix.url = "github:yaxitech/ragenix";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    my-secrets = {
      url = "github:KeishiS/my-secrets/main";
      flake = false;
    };

    nix-ld = {
      url = "github:Mic92/nix-ld/2.0.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-ld,
      ...
    }@inputs:
    {
      nixosConfigurations.NixOS-keishis-X13 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          nix-ld.nixosModules.nix-ld

          ./default.nix
          ./sway.nix
          ./hyprland.nix
          ./i3.nix
          ./X13/configuration.nix
        ];
      };

      nixosConfigurations.NixOS-keishis-home = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          nix-ld.nixosModules.nix-ld

          ./default.nix
          ./sway.nix
          ./home-srv/configuration.nix
        ];
      };

      nixosConfigurations.NixOS-sandi-lenovo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./common.nix
        ];
      };
    };
}
