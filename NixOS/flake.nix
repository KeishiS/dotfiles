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

    keylytix = {
      url = "github:sandybox05/KeyLytix";
      flake = false;
    };

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
    };

    build-system-pkgs = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      sops-nix,
      disko,
      nix-ld,
      keylytix,

      # for keylytix-workspace
      pyproject-nix,
      uv2nix,
      build-system-pkgs,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShellNoCC {
        shellHook = ''
          export PATH="$PWD/scripts:$PATH"
        '';
      };

      nixosConfigurations.nixos-keishis-p14s = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          nix-ld.nixosModules.nix-ld
          sops-nix.nixosModules.sops
          disko.nixosModules.disko
          ./common.nix
          ./private.nix
          ./P14s/configuration.nix
          ./pkgs/networkmanager
          ./gui.nix
          ./hyprland.nix
        ];
      };

      nixosConfigurations.nixos-keishis-x13 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          nix-ld.nixosModules.nix-ld
          sops-nix.nixosModules.sops
          disko.nixosModules.disko
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
        inherit system;
        specialArgs = inputs;
        modules = [
          nix-ld.nixosModules.nix-ld
          sops-nix.nixosModules.sops
          disko.nixosModules.disko
          ./common.nix
          ./private.nix
          ./gui.nix
          ./sway.nix
          ./hyprland.nix
          ./home-srv/configuration.nix
        ];
      };

      nixosConfigurations.nixos-sandi-lenovo = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          nix-ld.nixosModules.nix-ld
          sops-nix.nixosModules.sops
          disko.nixosModules.disko
          ./common.nix
          ./srv-common.nix
          ./lenovo/configuration.nix
        ];
      };
      nixosConfigurations.nixos-sandi-n100 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          nix-ld.nixosModules.nix-ld
          sops-nix.nixosModules.sops
          disko.nixosModules.disko
          ./common.nix
          ./srv-common.nix
          ./N100/configuration.nix
          ./pkgs/ldap
          ./pkgs/netdata-client
        ];
      };
    };
}
