{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    sops-nix.url = "github:Mic92/sops-nix";
    ragenix.url = "github:yaxitech/ragenix";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-ld = {
      url = "github:nix-community/nix-ld/release-2.0.6";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      sops-nix,
      disko,
      ragenix,
      nix-ld,
      ...
    }@inputs:
    {
      nixosConfigurations.nixos-keishis-p14s = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          nix-ld.nixosModules.nix-ld
          sops-nix.nixosModules.sops
          disko.nixosModules.disko
          ./common.nix
          ./P14s/configuration.nix
          ./pkgs/networkmanager
          ./gui.nix
          ./hyprland.nix
        ];
      };

      nixosConfigurations.nixos-keishis-x13 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          nix-ld.nixosModules.nix-ld
          sops-nix.nixosModules.sops
          ragenix.nixosModules.default
          ./common.nix
          ./private.nix
          ./gui.nix
          ./sway.nix
          ./hyprland.nix
          ./i3.nix
          ./X13/configuration.nix
          ./pkgs/networkmanager
        ];
      };

      nixosConfigurations.nixos-keishis-home = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          nix-ld.nixosModules.nix-ld
          sops-nix.nixosModules.sops
          ./common.nix
          ./private.nix
          ./gui.nix
          ./sway.nix
          ./hyprland.nix
          ./home-srv/configuration.nix
        ];
      };

      nixosConfigurations.nixos-sandi-lenovo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          nix-ld.nixosModules.nix-ld
          sops-nix.nixosModules.sops
          ./common.nix
          ./srv-common.nix
          ./lenovo/configuration.nix
        ];
      };
      nixosConfigurations.nixos-sandi-n100 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          nix-ld.nixosModules.nix-ld
          sops-nix.nixosModules.sops
          ./common.nix
          ./srv-common.nix
          ./N100/configuration.nix
        ];
      };
    };
}
