{ ... }: {
  imports = [
    ./git
    ./herdr
    ./ssh-agent-forwarding
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

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };
}
