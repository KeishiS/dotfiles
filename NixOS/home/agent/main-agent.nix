{...}:{
    home = {
        username = "agent";
        homeDirectory = "/users/agent";
        sessionVariables = {
            VISUAL = "vim";
        };
    };
    imports = [
        ./common.nix
        ./git
        ./tmux
        ./zellij
    ];
}
