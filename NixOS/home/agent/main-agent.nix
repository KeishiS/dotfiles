{...}:{
    imports = [
        ./git
        ./tmux
        ./zellij
    ];

    home = {
        username = "agent";
        homeDirectory = "/users/agent";
        sessionPath = [ "$HOME/.local/bin" ];
        sessionVariables = {
            EDITOR = "vim";
            VISUAL = "vim";
        };
    };
}
