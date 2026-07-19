{
  imports = [
    ./common.nix
    ./agent-config
    ./agent-tools
  ];

  home.homeDirectory = "/home/agent";
}
