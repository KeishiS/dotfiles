{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    sops-nix.url = "github:Mic92/sops-nix";
    ragenix.url = "github:yaxitech/ragenix";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-ld = {
      url = "github:nix-community/nix-ld/2.0.4";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    keylytix = {
      url = "github:KeishiS/KeyLytix/main";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      sops-nix,
      ragenix,
      nix-ld,
      ...
    }@inputs:
    {
      nixosConfigurations.nixos-keishis-x13 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          nix-ld.nixosModules.nix-ld
          sops-nix.nixosModules.sops
          ragenix.nixosModules.default
          ./default.nix
          ./gui.nix
          ./sway.nix
          ./hyprland.nix
          ./i3.nix
          ./X13/configuration.nix
        ];
      };

      nixosConfigurations.nixos-keishis-home = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          nix-ld.nixosModules.nix-ld
          sops-nix.nixosModules.sops
          # ragenix.nixosModules.default
          ./default.nix
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
          # ragenix.nixosModules.default
          ./common.nix
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
          ./N100/configuration.nix
        ];
      };
    };
}
