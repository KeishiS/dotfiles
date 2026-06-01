{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    sops-nix.url = "github:Mic92/sops-nix";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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

    /*
        keylytix = {
          url = "github:sandybox05/KeyLytix";
          flake = false;
        };
    */

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
      # keylytix,

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
        config.allowUnfreePredicate =
          pkg:
          builtins.elem (nixpkgs.lib.getName pkg) [
            "terraform"
          ];
      };

      projectName = "dotfiles";
      entrypoint = pkgs.writeShellApplication {
        name = "sandbox-enter";
        runtimeInputs = with pkgs; [
          bashInteractive
          bat
          bubblewrap
          coreutils
          eza
          fd
          fzf
          ripgrep
          starship
          zsh
        ];
        text = ''
          export SANDBOX_BASH=${pkgs.bashInteractive}/bin/bash
          export SANDBOX_ZSH=${pkgs.zsh}/bin/zsh
          export PROJECT_NAME=${projectName}
          export SANDBOX_ZSHRC_TEMPLATE=${./flake-config/zshrc}
          export SANDBOX_NIX_CONF_TEMPLATE=${./flake-config/nix.conf}
          export SANDBOX_STARSHIP_TEMPLATE=${./flake-config/starship.toml}
          export SANDBOX_CACERT=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
          export STARSHIP_BIN=${pkgs.starship}/bin/starship
          ${builtins.readFile ./flake-config/sandbox-enter.sh}
        '';
      };

      mkHost =
        modules:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = inputs;
          modules = [
            nix-ld.nixosModules.nix-ld
            sops-nix.nixosModules.sops
            disko.nixosModules.disko
            ./modules/base
            ./modules/services/backup
            ./credentials.nix
          ]
          ++ modules;
        };
    in
    {
      devShells.${system} = {
        default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            gomplate
            nodejs_24
            pnpm
            ripgrep
            starship
            terraform
            uv
          ];
          shellHook = ''
            if [ -z "''${SKIP_AGENT_BWRAP:-}" ]; then
              exec ${entrypoint}/bin/sandbox-enter
            fi
          '';
        };

        plain = pkgs.mkShellNoCC {
          packages = with pkgs; [
            gomplate
            nodejs_24
            pnpm
            ripgrep
            starship
            terraform
            awscli2
            uv
            zsh

            age-plugin-yubikey
            rage
          ];
          shellHook = ''
            export PATH="$PWD/scripts:$PATH"
            export SHELL=${pkgs.zsh}/bin/zsh
            if [ -z "''${IN_NIX_DEVELOP_ZSH:-}" ]; then
              export IN_NIX_DEVELOP_ZSH=1
              exec "$SHELL" -i
            fi
          '';
        };
      };

      nixosConfigurations.nixos-keishis-p14s = mkHost [
        ./private.nix
        ./hosts/p14s/configuration.nix
        ./modules/services/networkmanager
        ./modules/profiles/laptop.nix
        ./modules/profiles/desktop.nix
        ./modules/profiles/bluetooth.nix
        ./modules/profiles/japanese.nix
        ./modules/profiles/yubikey.nix
        ./modules/profiles/hyprland.nix
      ];

      nixosConfigurations.nixos-keishis-home = mkHost [
        ./private.nix
        ./modules/profiles/desktop.nix
        ./modules/profiles/bluetooth.nix
        ./modules/profiles/japanese.nix
        ./modules/profiles/yubikey.nix
        ./modules/profiles/sway.nix
        ./modules/profiles/hyprland.nix
        ./hosts/home-srv/configuration.nix
        ./modules/services/networkmanager
      ];

      nixosConfigurations.nixos-sandi-m710q = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          nix-ld.nixosModules.nix-ld
          sops-nix.nixosModules.sops
          disko.nixosModules.disko
          ./modules/base
          ./modules/users/sandi.nix
          ./modules/profiles/server.nix
          ./modules/services/backup
          ./modules/services/networkmanager
          ./hosts/m710q/configuration.nix
        ];
      };

      nixosConfigurations.nixos-sandi-lenovo = mkHost [
        ./modules/users/sandi.nix
        ./modules/profiles/server.nix
        ./hosts/lenovo/configuration.nix
      ];

      nixosConfigurations.nixos-sandi-n100 = mkHost [
        ./modules/users/sandi.nix
        ./modules/profiles/server.nix
        ./hosts/n100/configuration.nix
      ];

      /*
        # retired
        nixosConfigurations.nixos-keishis-x13 = mkHost [
          ./private.nix
          ./modules/profiles/desktop.nix
          ./modules/profiles/bluetooth.nix
          ./modules/profiles/japanese.nix
          ./modules/profiles/yubikey.nix
          ./modules/profiles/sway.nix
          ./modules/profiles/hyprland.nix
          ./modules/profiles/i3.nix
          ./hosts/x13/configuration.nix
          ./modules/services/networkmanager
          ./modules/profiles/laptop.nix
        ];
      */
    };
}
