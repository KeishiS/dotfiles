{ pkgs, ... }:{
    # imports = [ ./common.nix ];
    home = {
        username = "agent";
        homeDirectory = "/home/agent";

        packages = with pkgs; [
            nodejs_26
        ];

        sessionVariables = {
            PNPM_HOME = "$HOME/.local/share/pnpm";
            PNPM_CONFIG_GLOBAL_BIN_DIR = "$HOME/.local/share/pnpm/bin";
        };
    };
}
