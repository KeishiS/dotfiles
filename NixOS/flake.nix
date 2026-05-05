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

      projectName = "dotfiles";
      entrypoint = pkgs.writeShellApplication {
        name = "sandbox-enter";
        runtimeInputs = with pkgs; [
          bashInteractive
          bash-completion
          bat
          bubblewrap
          coreutils
          eza
          fd
          fzf
          ripgrep
          starship
        ];
        text = ''
          export SANDBOX_BASH=${pkgs.bashInteractive}/bin/bash
          export PROJECT_NAME=${projectName}
          export SANDBOX_BASHRC_TEMPLATE=${./flake-config/bashrc}
          export SANDBOX_STARSHIP_TEMPLATE=${./flake-config/starship.toml}
          export SANDBOX_CACERT=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
          export BASH_COMPLETION_PATH=${pkgs.bash-completion}/share/bash-completion/bash_completion
          export STARSHIP_BIN=${pkgs.starship}/bin/starship
          ${builtins.readFile ./flake-config/sandbox-enter.sh}
        '';
      };
    in
    {
      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          nodejs_24
          pnpm
          ripgrep
          starship
          uv
        ];
        shellHook = ''
          # export PATH="$PWD/scripts:$PATH"
          if [ -z "''${SKIP_AGENT_BWRAP:-}" ]; then
            exec ${entrypoint}/bin/sandbox-enter
          fi
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
