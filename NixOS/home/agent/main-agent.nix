{...}:{
    home = {
        username = "agent";
        homeDirectory = "/users/agent";
        sessionVariables = {
            VISUAL = "vim";
        };
    };
    imports = [
        ./git
        ./tmux
        ./zellij
    ];
}
