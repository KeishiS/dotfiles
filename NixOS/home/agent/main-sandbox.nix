{ pkgs, ... }:{
    home = {
        username = "agent";
        homeDirectory = "/home/agent";

        packages = with pkgs; [
            nodejs_26
        ];

        sessionPath = [ "$HOME/.local/share/pnpm/bin" ];
        sessionVariables = {
            PNPM_HOME = "$HOME/.local/share/pnpm";
            PNPM_CONFIG_GLOBAL_BIN_DIR = "$HOME/.local/share/pnpm/bin";
        };
    };
    # imports = [ ./common.nix ];
}
