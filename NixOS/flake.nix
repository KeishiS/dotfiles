{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    ragenix.url = "github:yaxitech/ragenix";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    my-secrets = {
      url = "github:KeishiS/my-secrets/main";
      flake = false;
    };

    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nix-ld, ... }@inputs: {
    nixosConfigurations.NixOS-keishis-X13 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs;
      modules = [
        ./default.nix
        ./sway.nix
        ./X13/configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.keishis = import ./home/default.nix;
        }
        nix-ld.nixosModules.nix-ld
      ];
    };

    nixosConfigurations.NixOS-keishis-home = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs;
      modules = [
        ./default.nix
        ./sway.nix
        ./home-srv/configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.keishis = import ./home/default.nix;
        }
        nix-ld.nixosModules.nix-ld
      ];
    };
  };
}
