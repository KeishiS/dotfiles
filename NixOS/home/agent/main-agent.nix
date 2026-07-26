{ ... }: {
  imports = [
    ./git
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
    shellAliases = {
      sandbox = "agent-sandbox --mount-file /sandbox/by-uid/$(id -u)/codex-config-template.toml /workspace/.codex/config.toml";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };
}
